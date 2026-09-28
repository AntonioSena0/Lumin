package br.com.mailservice.service;

import br.com.mailservice.dto.event.MailEvent;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class MailServiceImpl implements MailService {

    private final RestTemplate restTemplate;
    private final String resendApiKey;
    private final String from;

    public MailServiceImpl(
            RestTemplate restTemplate,
            @Value("${RESEND_API_KEY:}") String resendApiKey,
            @Value("${MAIL_FROM:noreply@lumin.com}") String from
    ) {
        this.restTemplate = restTemplate;
        this.resendApiKey = resendApiKey;
        this.from = from;
    }

    @Override
    public void sendEmail(MailEvent event) {
        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(resendApiKey);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = Map.of(
                "from", "Lumin <" + from + ">",
                "to", List.of(event.to()),
                "subject", event.subject(),
                "html", buildCodeHtml(event.vars().get("code")));

        try {
            restTemplate.postForObject("https://api.resend.com/emails",
                    new HttpEntity<>(body, headers), Map.class);
        } catch (HttpClientErrorException e) {
            throw new IllegalArgumentException("E-mail rejeitado: " + e.getStatusCode(), e);
        }
    }

    private String buildCodeHtml(String code) {
        return """
                <!DOCTYPE html>
                <html lang="pt-BR">
                <body style="margin:0;padding:0;background-color:#070111;font-family:Arial,Helvetica,sans-serif;">
                  <table width="100%" cellpadding="0" cellspacing="0" style="padding:32px 16px;">
                    <tr><td align="center">
                      <table width="480" cellpadding="0" cellspacing="0" style="background-color:#171020;border-radius:12px;overflow:hidden;">
                        <tr><td align="center" style="padding:28px 24px;background:linear-gradient(135deg,#6A00F4,#D000D9);">
                          <div style="font-size:26px;font-weight:bold;color:#F6F0FF;letter-spacing:4px;">LUMIN</div>
                          <div style="font-size:13px;color:#F6F0FF;opacity:0.85;margin-top:4px;">Explore &middot; Aprenda &middot; Conecte-se</div>
                        </td></tr>
                        <tr><td align="center" style="padding:32px 24px 8px;color:#F6F0FF;font-size:16px;">
                          Seu c&oacute;digo de verifica&ccedil;&atilde;o
                        </td></tr>
                        <tr><td align="center" style="padding:12px 24px 8px;">
                          <div style="display:inline-block;font-size:34px;font-weight:bold;letter-spacing:10px;color:#F6F0FF;background-color:#272130;border:1px solid #D000D9;border-radius:10px;padding:14px 20px 14px 30px;">"""
                + code + """
                </div>
                        </td></tr>
                        <tr><td align="center" style="padding:16px 24px;color:#8F829D;font-size:13px;">
                          V&aacute;lido por 10 minutos. Se voc&ecirc; n&atilde;o solicitou, ignore este e-mail.
                        </td></tr>
                        <tr><td align="center" style="padding:20px 24px 28px;color:#8F829D;font-size:11px;">
                          &copy; 2026 Lumin. Todos os direitos reservados.
                        </td></tr>
                      </table>
                    </td></tr>
                  </table>
                </body>
                </html>
                """;
    }
}
