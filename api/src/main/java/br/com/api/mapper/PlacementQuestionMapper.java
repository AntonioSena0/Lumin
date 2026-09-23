package br.com.api.mapper;

import br.com.api.dto.response.PlacementQuestionResponse;
import br.com.api.entity.PlacementQuestion;
import lombok.experimental.UtilityClass;

@UtilityClass
public class PlacementQuestionMapper {

    public PlacementQuestionResponse toPlacementQuestionResponse(PlacementQuestion placementQuestion){

        return PlacementQuestionResponse
                .builder()
                .id(placementQuestion.getId())
                .language(LanguageMapper.toLanguageResponse(placementQuestion.getLanguage()))
                .level(placementQuestion.getLevel())
                .question(placementQuestion.getQuestion())
                .options(placementQuestion.getOptions())
                .createdAt(placementQuestion.getCreatedAt())
                .build();

    }

}
