package io.swagger.repository;

import com.google.common.base.Preconditions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import io.swagger.model.Profile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;

@Service
public class UserRepositoryService {

    private static final Logger LOGGER = LoggerFactory.getLogger(UserRepositoryService.class);

    @Autowired
    private UserRepository userRepository;

    Timestamp timestamp = new Timestamp(System.currentTimeMillis());

    public Profile update(Profile updateEntry) {
        long start = System.currentTimeMillis();
        Preconditions.checkNotNull(updateEntry, "User profile cannot be null");

        LOGGER.info("Updating user profile for user=%s", updateEntry.getId());
        Profile existingUser = findOne(updateEntry.getId());
        if (existingUser == null) {
            throw new NullPointerException("Unable to locate user");
        }

        existingUser.setTotalTrips(updateEntry.getTotalTrips() == null? existingUser.getTotalTrips() : updateEntry.getTotalTrips());
        existingUser.setTotalDistance(updateEntry.getTotalDistance() == null ? existingUser.getTotalTrips() : updateEntry.getTotalDistance());
        existingUser.setTotalTime(updateEntry.getTotalTime() == null ? existingUser.getTotalTime() : updateEntry.getTotalTime());
        existingUser.setHardStops(updateEntry.getHardStops() == null ? existingUser.getHardStops() : updateEntry.getHardStops());
        existingUser.setHardAccelerations(updateEntry.getHardAccelerations() == null ? existingUser.getHardAccelerations() : updateEntry.getHardAccelerations());
        existingUser.setFuelConsumption(updateEntry.getFuelConsumption() == null ? existingUser.getFuelConsumption() : updateEntry.getFuelConsumption());
        existingUser.setMaxSpeed(updateEntry.getMaxSpeed() == null ? existingUser.getMaxSpeed() : updateEntry.getMaxSpeed());
        existingUser.setRating(updateEntry.getRating() == null ? existingUser.getRating() : updateEntry.getRating());
        existingUser.setRating(updateEntry.getRanking() == null ? existingUser.getRanking() : updateEntry.getRanking());

        Profile userProfile = save(existingUser);
        long end = System.currentTimeMillis();
        long timeElapsed = end - start;

        LOGGER.info("Update method called: on {} and response time in ms: {}", timestamp, timeElapsed);
        return userProfile;
    }

    public Profile save(Profile newProfile) {
        Preconditions.checkNotNull(newProfile, "User profile cannot be null");

        long start = System.currentTimeMillis();
        Profile userProfile = userRepository.save(newProfile);
        long end = System.currentTimeMillis();
        long timeElapsed = end - start;

        LOGGER.info("Save method called: on {} and response time in ms: {}", timestamp, timeElapsed);
        return userProfile;
    }

    private Profile findOne(String Id) {
        Preconditions.checkNotNull(Id, "User Id cannot be null");
        return userRepository.findOne(Id);
    }

}
