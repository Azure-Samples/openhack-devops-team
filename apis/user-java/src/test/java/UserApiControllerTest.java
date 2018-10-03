import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.api.UserApiController;
import io.swagger.model.Profile;
import io.swagger.repository.UserRepositoryService;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.mockito.runners.MockitoJUnitRunner;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.mockito.InjectMocks;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.nio.charset.Charset;

import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;

@RunWith(MockitoJUnitRunner.class)
public class UserApiControllerTest {

    public static final MediaType APPLICATION_JSON_UTF8 = new MediaType(MediaType.APPLICATION_JSON.getType(), MediaType.APPLICATION_JSON.getSubtype(), Charset.forName("utf8"));

    @InjectMocks
    private UserApiController userApiController;

    private MockMvc mockMvc;

    private Profile profile;

    @Mock
    HttpServletRequest httpServletRequest;

    @Mock
    UserRepositoryService userRepositoryService;

    @Before
    public void setup() {

        // this must be called for the @Mock annotations above to be processed
        // and for the mock service to be injected into the controller under
        // test.
        MockitoAnnotations.initMocks(this);
        mockMvc = MockMvcBuilders.standaloneSetup(userApiController).build();
        profile = new Profile();
        profile.setFirstName("test");
        profile.setUserId("userId");
        profile.setRanking(1);
        profile.setTotalDistance(1000f);
        profile.setId("2");
    }

    @Test
    public void testSave() throws Exception {
        when(httpServletRequest.getHeader("Accept")).thenReturn("accept,application/json;charset=UTF-8");
        when(userRepositoryService.save(profile)).thenReturn(profile);
        mockMvc.perform(
                post("/user-java/2")
                        .contentType(MediaType.APPLICATION_JSON_UTF8)
                        .accept(MediaType.APPLICATION_JSON)
                        .content(convertObjectToJsonBytes(profile))
        )
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8));
        verify(userRepositoryService, times(1)).save(profile);
    }

    @Test
    public void testSave_shouldNotImplemented() throws Exception {
        mockMvc.perform(
                post("/user-java/2")
                        .contentType(MediaType.APPLICATION_JSON_UTF8)
                        .accept(MediaType.APPLICATION_JSON)
                        .content(convertObjectToJsonBytes(profile))
        )
                .andExpect(MockMvcResultMatchers.status().is5xxServerError());
    }

    @Test
    public void testUpdate_shouldNotImplemented() throws Exception {
        mockMvc.perform(
                patch("/user-java/2")
                        .contentType(MediaType.APPLICATION_JSON_UTF8)
                        .accept(MediaType.APPLICATION_JSON)
                        .content(convertObjectToJsonBytes(profile))
        )
                .andExpect(MockMvcResultMatchers.status().is5xxServerError());
    }

    @Test
    public void testUpdate() throws Exception {
        profile.setRanking(2);
        profile.setTotalDistance(2500F);
        when(httpServletRequest.getHeader("Accept")).thenReturn("accept,application/json;charset=UTF-8");
        when(userRepositoryService.update(profile)).thenReturn(profile);
        mockMvc.perform(
                patch("/user-java/2")
                        .contentType(APPLICATION_JSON_UTF8)
                        .content(convertObjectToJsonBytes(profile)))
                .andExpect(MockMvcResultMatchers.status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON_UTF8));
        verify(userRepositoryService, times(1)).update(profile);

    }

    public static byte[] convertObjectToJsonBytes(Object object) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        return mapper.writeValueAsBytes(object);
    }
}
