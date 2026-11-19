import * as THREE from "three";

export type MugScene = {
  state: { progress: number };
  dispose: () => void;
};

/** Monta a cena da caneca 3D e a posiciona conforme state.progress: abertura, centro do celular e lado do cartão da palavra. */
export function createMugScene(canvas: HTMLCanvasElement): MugScene {
  const renderer = new THREE.WebGLRenderer({ canvas, antialias: true, alpha: true });
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.toneMapping = THREE.ACESFilmicToneMapping;

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(32, 1, 0.1, 100);

  const mug = new THREE.Group();
  const ceramic = new THREE.MeshPhysicalMaterial({
    color: "#efe6ff",
    roughness: 0.32,
    clearcoat: 1,
    clearcoatRoughness: 0.18,
    sheen: 0.4,
    sheenColor: new THREE.Color("#d000d9"),
  });
  const profile = [
    [0, -0.8], [0.7, -0.8], [0.78, -0.72], [0.82, 0.74], [0.86, 0.8],
    [0.78, 0.82], [0.74, -0.6], [0, -0.6],
  ].map(([x, y]) => new THREE.Vector2(x, y));
  mug.add(new THREE.Mesh(new THREE.LatheGeometry(profile, 96), ceramic));

  const handle = new THREE.Mesh(new THREE.TorusGeometry(0.4, 0.09, 24, 64, Math.PI), ceramic);
  handle.rotation.z = -Math.PI / 2;
  handle.position.x = 0.8;
  mug.add(handle);

  const coffee = new THREE.Mesh(
    new THREE.CircleGeometry(0.75, 64),
    new THREE.MeshStandardMaterial({ color: "#2b1206", roughness: 0.15 }),
  );
  coffee.rotation.x = -Math.PI / 2;
  coffee.position.y = 0.52;
  mug.add(coffee);

  mug.rotation.x = 0.28;
  scene.add(mug);

  scene.add(new THREE.AmbientLight("#ffffff", 0.35));
  const key = new THREE.DirectionalLight("#ffffff", 1.6);
  key.position.set(2, 3, 4);
  scene.add(key);
  const magenta = new THREE.PointLight("#d000d9", 30, 12);
  magenta.position.set(-3, 1, 2);
  scene.add(magenta);
  const cyan = new THREE.PointLight("#52e7ff", 22, 12);
  cyan.position.set(3, -1.5, 1.5);
  scene.add(cyan);

  const dustGeometry = new THREE.BufferGeometry();
  const positions = new Float32Array(600 * 3);
  for (let i = 0; i < positions.length; i++) positions[i] = (Math.random() - 0.5) * 14;
  dustGeometry.setAttribute("position", new THREE.BufferAttribute(positions, 3));
  const dust = new THREE.Points(
    dustGeometry,
    new THREE.PointsMaterial({ color: "#8f6bff", size: 0.02, transparent: true, opacity: 0.7 }),
  );
  scene.add(dust);

  const state = { progress: 0 };
  let width = 0;
  let height = 0;
  let frame = 0;
  let visible = true;

  const resize = () => {
    width = canvas.clientWidth;
    height = canvas.clientHeight;
    renderer.setSize(width, height, false);
    camera.aspect = width / height;
    camera.updateProjectionMatrix();
  };

  const clock = new THREE.Clock();
  const render = () => {
    frame = requestAnimationFrame(render);
    if (!visible) return;
    const t = clock.getElapsedTime();
    const p = state.progress;
    const wide = width > height;
    const approach = Math.min(p / 0.45, 1);
    const ease = approach * approach * (3 - 2 * approach);

    const open = Math.min(Math.max((p - 0.63) / 0.14, 0), 1);
    const openEase = open * open * (3 - 2 * open);

    const startX = wide ? 1.9 : 0;
    const startY = wide ? 0 : -1.6;
    const panelX = wide ? -1.25 * Math.min(camera.aspect / 1.6, 1.3) : 0;
    const panelY = wide ? 0 : 1.05;
    mug.position.set(
      startX * (1 - ease) + panelX * openEase,
      startY * (1 - ease) + panelY * openEase + Math.sin(t * 1.2) * 0.06,
      0,
    );
    const fit = Math.min(1, camera.aspect / 0.65);
    const panelScale = wide ? 1 + openEase * 0.15 : 1 - openEase;
    mug.scale.setScalar((0.46 - ease * 0.1) * panelScale * fit);
    mug.rotation.y = t * 0.35 + p * Math.PI * 1.5;
    camera.position.set(0, 0, 6.4);
    camera.lookAt(0, 0, 0);
    dust.rotation.y = t * 0.02;
    renderer.render(scene, camera);
  };

  const observer = new IntersectionObserver(([entry]) => (visible = entry.isIntersecting));
  observer.observe(canvas);
  window.addEventListener("resize", resize);
  resize();
  render();

  return {
    state,
    dispose: () => {
      cancelAnimationFrame(frame);
      observer.disconnect();
      window.removeEventListener("resize", resize);
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
