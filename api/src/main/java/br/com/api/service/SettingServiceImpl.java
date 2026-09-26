package br.com.api.service;

import br.com.api.dto.request.SettingUpdateRequest;
import br.com.api.dto.response.SettingResponse;
import br.com.api.entity.Language;
import br.com.api.entity.Setting;
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

        Optional<Setting> setting = repository.findByIdWithLanguage(userId);
        if (setting.isPresent()){
            return SettingMapper.toSettingResponse(setting.get());
        }

        if(userRepository.existsById(userId)){
            throw new RuntimeException("Configuração não encontrada");
        } else {
            throw new RuntimeException("Usuário não encontrado");
        }

    }

    @Override
    @Transactional
    public SettingResponse updateByUserId(SettingUpdateRequest request, Long userId) {

        userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Usuário não encontrado"));

        Setting setting = repository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Configuração não encontrada"));

        if(request.appLanguage() != null){

            Language language = languageRepository.findById(request.appLanguage())
                            .orElseThrow(() -> new RuntimeException("Língua não encontrada"));

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
