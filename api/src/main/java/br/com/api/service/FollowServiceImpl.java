package br.com.api.service;

import br.com.api.dto.response.PublicProfileResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.entity.Follow;
import br.com.api.entity.FollowId;
import br.com.api.entity.User;
import br.com.api.exception.BusinessException;
import br.com.api.exception.NotFoundException;
import br.com.api.mapper.AvatarMapper;
import br.com.api.mapper.LanguageMapper;
import br.com.api.mapper.UserMapper;
import br.com.api.repository.FollowRepository;
import br.com.api.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@AllArgsConstructor
public class FollowServiceImpl implements FollowService {

    private final FollowRepository repository;
    private final UserRepository userRepository;

    /** Cria a relação de seguir, impedindo seguir a si mesmo e ignorando relações já existentes. */
    @Override
    @Transactional
    public void follow(Long meId, Long targetId) {

        if(meId.equals(targetId)){
            throw new BusinessException("CANNOT_FOLLOW_SELF", "Você não pode seguir a si mesmo");
        }

        if(!userRepository.existsById(targetId)){
            throw new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado");
        }

        FollowId id = new FollowId(meId, targetId);

        if(repository.existsById(id)){
            return;
        }

        repository.save(Follow.builder().id(id).build());

    }

    /** Remove a relação de seguir, se existir. */
    @Override
    @Transactional
    public void unfollow(Long meId, Long targetId) {
        repository.deleteById(new FollowId(meId, targetId));
    }

    /** Monta o perfil público com contagens de seguidores e seguindo e o estado de seguir do usuário logado. */
    @Override
    public PublicProfileResponse profile(Long meId, Long targetId) {

        User user = userRepository.findByIdWithRelations(targetId)
                .orElseThrow(() -> new NotFoundException("USER_NOT_FOUND", "Usuário não encontrado"));

        return PublicProfileResponse
                .builder()
                .id(user.getId())
                .name(user.getName())
                .avatar(AvatarMapper.toAvatarResponse(user.getAvatar()))
                .nativeLanguage(LanguageMapper.toLanguageResponse(user.getNativeLanguage()))
                .chosenLanguage(LanguageMapper.toLanguageResponse(user.getChosenLanguage()))
                .followers(repository.countByIdFollowedId(targetId))
                .following(repository.countByIdFollowerId(targetId))
                .followedByMe(!meId.equals(targetId) && repository.existsById(new FollowId(meId, targetId)))
                .me(meId.equals(targetId))
                .build();

    }

    /** Lista os seguidores de um usuário. */
    @Override
    public Page<UserResponse> followers(Long userId, Pageable pageable) {
        return userRepository.findFollowersOf(userId, pageable).map(UserMapper::toUserResponse);
    }

    /** Lista os usuários que um usuário segue. */
    @Override
    public Page<UserResponse> following(Long userId, Pageable pageable) {
        return userRepository.findFollowedBy(userId, pageable).map(UserMapper::toUserResponse);
    }

}
