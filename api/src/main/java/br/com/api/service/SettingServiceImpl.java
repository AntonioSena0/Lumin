package br.com.api.service;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import br.com.api.entity.Language;
import br.com.api.entity.Setting;
import br.com.api.exception.NotFoundException;
import br.com.api.mapper.SettingMapper;
import br.com.api.repository.LanguageRepository;
import br.com.api.repository.SettingRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@AllArgsConstructor
public class SettingServiceImpl implements SettingService {

    private final SettingRepository repository;
    private final UserRepository userRepository;
    private final LanguageRepository languageRepository;

    @Override
    public SettingResponse findByUserId(Long userId) {
        return SettingMapper.toSettingResponse(repository.findByIdWithLanguage(userId)
                .orElseThrow(() -> new NotFoundException("SETTING_NOT_FOUND", "Configuração não encontrada")));
    }

    @Override
    @Transactional
    public SettingResponse updateByUserId(SettingUpdateRequest request, Long userId) {

        Setting setting = repository.findByIdWithLanguage(userId)
                .orElseThrow(() -> new NotFoundException("SETTING_NOT_FOUND", "Configuração não encontrada"));

        if(request.appLanguage() != null){

            Language language = languageRepository.findById(request.appLanguage())
                            .orElseThrow(() -> new NotFoundException("LANGUAGE_NOT_FOUND", "Língua não encontrada"));

            setting.setAppLanguage(language);
        }

        if(request.notifyDaily() != null){
            setting.setNotifyDaily(request.notifyDaily());
        }

        if(request.notifyReview() != null){
            setting.setNotifyReview(request.notifyReview());
        }

        if(request.voice() != null){
            setting.setVoice(request.voice());
        }

        return SettingMapper.toSettingResponse(setting);

    }
}
