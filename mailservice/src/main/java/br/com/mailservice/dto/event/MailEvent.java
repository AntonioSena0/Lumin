package br.com.mailservice.dto.event;

import lombok.Builder;

import java.util.Map;

@Builder
public record MailEvent (

        String to,
        String subject,
        String template,
        Map<String, String> vars

) {}
