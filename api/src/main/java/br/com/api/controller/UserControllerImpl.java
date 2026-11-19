package br.com.api.controller;

import br.com.api.dto.response.PageResponse;
import br.com.api.dto.response.PublicProfileResponse;
import br.com.api.dto.response.UserResponse;
import br.com.api.service.FollowService;
import br.com.api.service.UserService;
import br.com.api.util.SecurityUtils;
import lombok.AllArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/lumin/users")
@AllArgsConstructor
public class UserControllerImpl implements UserController{

    private final UserService service;
    private final FollowService followService;

    /** Lista usuários paginados, filtrando pelo nome quando o parâmetro q é informado. */
    @Override
    @GetMapping
    public ResponseEntity<PageResponse<UserResponse>> findAll(
            @RequestParam(required = false) String q,
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ){

        return ResponseEntity.ok(PageResponse.from(service.search(q, pageable)));

    }

    @Override
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> findById(@PathVariable Long id){

        return ResponseEntity.ok(service.findById(id));

    }

    /** Retorna o perfil público de um usuário com contagem de seguidores e se o usuário logado o segue. */
    @Override
    @GetMapping("/{id}/profile")
    public ResponseEntity<PublicProfileResponse> profile(@PathVariable Long id) {
        return ResponseEntity.ok(followService.profile(SecurityUtils.currentUserId(), id));
    }

    /** Faz o usuário logado seguir outro usuário. */
    @Override
    @PostMapping("/{id}/follow")
    public ResponseEntity<Void> follow(@PathVariable Long id) {
        followService.follow(SecurityUtils.currentUserId(), id);
        return ResponseEntity.noContent().build();
    }

    /** Faz o usuário logado deixar de seguir outro usuário. */
    @Override
    @DeleteMapping("/{id}/follow")
    public ResponseEntity<Void> unfollow(@PathVariable Long id) {
        followService.unfollow(SecurityUtils.currentUserId(), id);
        return ResponseEntity.noContent().build();
    }

    /** Lista os seguidores de um usuário. */
    @Override
    @GetMapping("/{id}/followers")
    public ResponseEntity<PageResponse<UserResponse>> followers(
            @PathVariable Long id,
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(PageResponse.from(followService.followers(id, pageable)));
    }

    /** Lista os usuários que um usuário segue. */
    @Override
    @GetMapping("/{id}/following")
    public ResponseEntity<PageResponse<UserResponse>> following(
            @PathVariable Long id,
            @PageableDefault(sort = "id", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(PageResponse.from(followService.following(id, pageable)));
    }

}
