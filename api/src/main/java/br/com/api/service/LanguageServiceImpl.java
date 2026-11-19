package br.com.api.service;

import br.com.api.dto.response.LanguageResponse;
import br.com.api.exception.NotFoundException;
import br.com.api.mapper.LanguageMapper;
import br.com.api.repository.LanguageRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.List;
import java.util.Map;

@Service
public class LanguageServiceImpl implements LanguageService{

    private static final String PORTUGUESE = "pt-BR";
    private static final String ENGLISH = "en";

    private final LanguageRepository repository;
    private final RestTemplate restTemplate;

    public LanguageServiceImpl(LanguageRepository repository, RestTemplate restTemplate) {
        this.repository = repository;
        this.restTemplate = restTemplate;
    }

    @Override
    public List<LanguageResponse> findAll() {
        return repository.findAll()
                .stream()
                .map(LanguageMapper::toLanguageResponse)
                .toList();
    }

    @Override
    public LanguageResponse findById(Integer id) {
        return LanguageMapper.toLanguageResponse(repository.findById(id)
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua não encontrada")));
    }


    /** Define o idioma do app: Brasil pelo IP vira português, outro país vira inglês e, sem país, usa o Accept-Language. */
    @Override
    public LanguageResponse detect(String clientIp, String acceptLanguage) {
        String country = lookupCountry(clientIp);
        String code;
        if (country != null) {
            code = "BR".equalsIgnoreCase(country) ? PORTUGUESE : ENGLISH;
        } else {
            code = acceptLanguage != null && acceptLanguage.trim().toLowerCase().startsWith("pt") ? PORTUGUESE : ENGLISH;
        }
        return LanguageMapper.toLanguageResponse(repository.findByCode(code)
                .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua não encontrada")));
    }

    /** Consulta o país do IP no api.country.is, retornando null para IP privado ou falha na consulta. */
    private String lookupCountry(String ip) {
        if (ip == null || ip.isBlank() || isPrivate(ip)) {
            return null;
        }
        try {
            Map<?, ?> body = restTemplate.getForObject("https://api.country.is/" + ip, Map.class);
            Object country = body == null ? null : body.get("country");
            return country instanceof String c && !c.isBlank() ? c : null;
        } catch (RestClientException e) {
            return null;
        }
    }

    /** Indica se o IP é inválido, local ou privado, aceitando apenas IPs literais para não disparar DNS. */
    private boolean isPrivate(String ip) {
        boolean literal = ip.matches("[0-9.]+") || (ip.contains(":") && ip.matches("[0-9a-fA-F:.]+"));
        if (!literal) {
            return true;
        }
        try {
            InetAddress address = InetAddress.getByName(ip);
            return address.isLoopbackAddress() || address.isSiteLocalAddress()
                    || address.isLinkLocalAddress() || address.isAnyLocalAddress();
        } catch (UnknownHostException e) {
            return true;
        }
    }

    /** Extrai o IP do cliente: primeiro endereço do X-Forwarded-For ou o endereço remoto da conexão. */
    public static String clientIp(String forwardedFor, String remoteAddr) {
        if (forwardedFor != null && !forwardedFor.isBlank()) {
            return forwardedFor.split(",")[0].trim();
        }
        return remoteAddr;
    }

}
