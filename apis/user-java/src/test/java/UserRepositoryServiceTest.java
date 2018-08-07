import io.swagger.model.Profile;
import io.swagger.repository.UserRepository;
import io.swagger.repository.UserRepositoryService;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;
import static org.mockito.Matchers.any;
import static org.mockito.Mockito.*;

@RunWith(MockitoJUnitRunner.class)
public class UserRepositoryServiceTest {

    private static final String USER_ID = "test1";
    private static final String ID = "1234";
    private static final String FIRST_NAME = "test";
    private static final String LAST_NAME = "lastname";
    private static final int RANKING = 1;
    private static final float TOTAL_DISTANCE = 1000;

    private Profile profile;

    private Integer ranking = 2;
    private Float distance  = 2000F;

    @Mock
    UserRepository userRepository;

    @InjectMocks
    UserRepositoryService userRepositoryService;

    @Before
    public void setUp() {
        profile = new Profile();
        profile.setUserId(USER_ID);
        profile.setId(ID);
        profile.setFirstName(FIRST_NAME);
        profile.setLastName(LAST_NAME);
        profile.setRanking(RANKING);
        profile.setTotalDistance(TOTAL_DISTANCE);
    }

    @After
    public void tearDown() {
        profile = null;
    }

    @Test
    public void testSave() {
        when(userRepository.save(any(Profile.class))).thenReturn(profile);
        assertNotNull(userRepositoryService.save(profile));
    }

    @Test
    public void testUpdate() {
        when(userRepository.findOne(ID)).thenReturn(profile);
        profile.setRanking(ranking);
        profile.setTotalDistance(distance);
        when(userRepository.save(profile)).thenReturn(profile);
        Profile updated = userRepositoryService.update(profile);
        assertEquals(ranking, updated.getRanking());
        assertEquals(distance, updated.getTotalDistance());
    }

    @Test
    public void testUpdate_shouldThrowException() {
        when(userRepository.findOne(USER_ID)).thenReturn(null);
        try {
            userRepositoryService.update(profile);
            fail("Unable to locate user");

        }catch (NullPointerException e) {
            assertEquals("Unable to locate user", e.getMessage());
        }
        verify(userRepository, never()).save(profile);
    }
}
