package br.com.api.mapper;

import br.com.api.dto.response.SettingResponse;
import br.com.api.entity.Setting;
import lombok.experimental.UtilityClass;

@UtilityClass
public class SettingMapper {

    public SettingResponse toSettingResponse(Setting setting){

        return SettingResponse
                .builder()
                .userId(setting.getUserId())
                .appLanguage(LanguageMapper.toLanguageResponse(setting.getAppLanguage()))
                .notifyDaily(setting.isNotifyDaily())
                .notifyReview(setting.isNotifyReview())
                .voice(setting.getVoice())
                .updatedAt(setting.getUpdatedAt())
                .build();

    }

}
