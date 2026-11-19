import * as THREE from "three";

export type GlobeScene = {
  state: { progress: number };
  dispose: () => void;
};

const RADIUS = 1;

/** Converte latitude e longitude em um ponto na superfície da esfera. */
function toVector(lat: number, lon: number, radius = RADIUS) {
  const phi = THREE.MathUtils.degToRad(90 - lat);
  const theta = THREE.MathUtils.degToRad(lon + 180);
  return new THREE.Vector3(-radius * Math.sin(phi) * Math.cos(theta), radius * Math.cos(phi), radius * Math.sin(phi) * Math.sin(theta));
}

/** Material com brilho nas bordas (fresnel), usado no núcleo e na atmosfera do planeta. */
function fresnel(color: string, power: number, intensity: number, side: THREE.Side) {
  return new THREE.ShaderMaterial({
    uniforms: { color: { value: new THREE.Color(color) }, power: { value: power }, intensity: { value: intensity } },
    vertexShader: `
      varying vec3 vNormal;
      varying vec3 vView;
      void main() {
        vec4 world = modelViewMatrix * vec4(position, 1.0);
        vNormal = normalize(normalMatrix * normal);
        vView = normalize(-world.xyz);
        gl_Position = projectionMatrix * world;
      }`,
    fragmentShader: `
      uniform vec3 color;
      uniform float power;
      uniform float intensity;
      varying vec3 vNormal;
      varying vec3 vView;
      void main() {
        float f = pow(1.0 - abs(dot(vNormal, vView)), power) * intensity;
        gl_FragColor = vec4(color * f, f);
      }`,
    side,
    transparent: true,
    depthWrite: false,
    blending: THREE.AdditiveBlending,
  });
}

/** Monta o planeta roxo pontilhado com atmosfera, anel e rótulos de palavras que acompanham a rotação. */
export function createGlobeScene(canvas: HTMLCanvasElement, labels: HTMLElement[]): GlobeScene {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(devicePixelRatio, 2));
  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(35, 1, 0.1, 100);

  const system = new THREE.Group();
  scene.add(system);
  const globe = new THREE.Group();
  globe.rotation.z = THREE.MathUtils.degToRad(-14);
  system.add(globe);

  globe.add(new THREE.Mesh(new THREE.SphereGeometry(RADIUS * 0.985, 64, 64), new THREE.MeshBasicMaterial({ color: "#0d0420" })));
  globe.add(new THREE.Mesh(new THREE.SphereGeometry(RADIUS, 64, 64), fresnel("#8f4dff", 2.2, 1.4, THREE.FrontSide)));
  system.add(new THREE.Mesh(new THREE.SphereGeometry(RADIUS * 1.22, 64, 64), fresnel("#a64dff", 3.5, 1.6, THREE.BackSide)));

  const dotsMaterial = new THREE.PointsMaterial({ size: 0.022, vertexColors: true, transparent: true, opacity: 0.95, depthWrite: false });
  const dots = new THREE.Points(new THREE.BufferGeometry(), dotsMaterial);
  globe.add(dots);
  fetch("/globe/land-dots.json")
    .then((r) => r.json())
    .then((points: [number, number][]) => {
      const positions = new Float32Array(points.length * 3);
      const colors = new Float32Array(points.length * 3);
      const magenta = new THREE.Color("#d000d9");
      const violet = new THREE.Color("#8f6bff");
      const cyan = new THREE.Color("#52e7ff");
      points.forEach(([lat, lon], i) => {
        toVector(lat, lon, RADIUS * 1.003).toArray(positions, i * 3);
        const t = (lat + 60) / 140;
        const c = t < 0.5 ? cyan.clone().lerp(violet, t * 2) : violet.clone().lerp(magenta, (t - 0.5) * 2);
        c.toArray(colors, i * 3);
      });
      dots.geometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
      dots.geometry.setAttribute("color", new THREE.BufferAttribute(colors, 3));
    })
    .catch(() => undefined);

  const ring = new THREE.Mesh(
    new THREE.TorusGeometry(RADIUS * 1.55, 0.006, 8, 200),
    new THREE.MeshBasicMaterial({ color: "#d000d9", transparent: true, opacity: 0.55 }),
  );
  ring.rotation.set(THREE.MathUtils.degToRad(72), THREE.MathUtils.degToRad(12), 0);
  system.add(ring);

  const orbiters = new THREE.Group();
  const orbitPositions = new Float32Array(160 * 3);
  for (let i = 0; i < 160; i++) {
    const a = Math.random() * Math.PI * 2;
    const r = RADIUS * (1.45 + Math.random() * 0.25);
    orbitPositions.set([Math.cos(a) * r, (Math.random() - 0.5) * 0.08, Math.sin(a) * r], i * 3);
  }
  const orbitGeometry = new THREE.BufferGeometry();
  orbitGeometry.setAttribute("position", new THREE.BufferAttribute(orbitPositions, 3));
  orbiters.add(new THREE.Points(orbitGeometry, new THREE.PointsMaterial({ color: "#52e7ff", size: 0.012, transparent: true, opacity: 0.8 })));
  orbiters.rotation.copy(ring.rotation);
  system.add(orbiters);

  const anchors = labels.map((_, i) => {
    const lat = -40 + ((i * 37) % 95);
    const lon = -180 + ((i * 83) % 360);
    return toVector(lat, lon, RADIUS * 1.04);
  });

  const state = { progress: 0 };
  let width = 0;
  let height = 0;
  let frame = 0;
  let visible = true;
  const temp = new THREE.Vector3();
  const normal = new THREE.Vector3();
  const toCamera = new THREE.Vector3();
  const center = new THREE.Vector3();

  const resize = () => {
    width = canvas.clientWidth;
    height = canvas.clientHeight;
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    camera.position.z = camera.aspect < 1 ? 8.2 : 5;
    system.position.set(camera.aspect < 1 ? 0 : 1.25, camera.aspect < 1 ? -1.35 : 0, 0);
    camera.updateProjectionMatrix();
  };

  const clock = new THREE.Clock();
  const render = () => {
    frame = requestAnimationFrame(render);
    if (!visible) return;
    const t = clock.getElapsedTime();
    globe.rotation.y = t * 0.08 + state.progress * Math.PI * 1.4;
    orbiters.rotation.y = t * 0.12;
    system.updateMatrixWorld(true);
    system.getWorldPosition(center);

    const narrow = camera.aspect < 1;
    labels.forEach((label, i) => {
      temp.copy(anchors[i]).applyMatrix4(globe.matrixWorld);
      normal.copy(temp).sub(center).normalize();
      toCamera.copy(camera.position).sub(temp).normalize();
      const facing = normal.dot(toCamera);
      temp.project(camera);
      const x = (temp.x * 0.5 + 0.5) * width;
      const y = (-temp.y * 0.5 + 0.5) * height;
      label.style.transform = `translate(${x}px, ${y}px) translate(-50%, -120%) scale(${0.75 + Math.max(facing, 0) * 0.35})`;
      const half = (label.offsetWidth * 1.1) / 2;
      const fits = x - half > 8 && x + half < width - 8 && (!narrow || (i < 8 && y > height * 0.52));
      label.style.opacity = fits && facing > 0.15 ? String(Math.min(1, (facing - 0.15) * 3)) : "0";
    });

    renderer.render(scene, camera);
  };

  const observer = new IntersectionObserver(([entry]) => (visible = entry.isIntersecting));
  observer.observe(canvas);
  addEventListener("resize", resize);
  resize();
  render();

  return {
    state,
    dispose: () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
      removeEventListener("resize", resize);
      renderer.dispose();
      scene.traverse((o) => {
        if (o instanceof THREE.Mesh || o instanceof THREE.Points) {
          o.geometry.dispose();
          (Array.isArray(o.material) ? o.material : [o.material]).forEach((m) => m.dispose());
        }
      });
    },
  };
}
