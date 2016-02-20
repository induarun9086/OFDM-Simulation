function userAllocation = UserScheduling(numberOfUsers,numberOfSamples,minAllocation)
    global userStatus;
    
    userAllocation = zeros(1,numberOfUsers);
    numberOfSamplesRemaining = numberOfSamples;
    
    % Assign the minAllocation (5 subcarriers) to all the active users
    userAllocation(:,1 : numberOfUsers) = userStatus(:,1 : numberOfUsers) * minAllocation;
    numberOfSamplesRemaining = numberOfSamplesRemaining - (minAllocation*numberOfUsers);
    
    % Permute the users
    j = randperm(numberOfUsers);
    
    % Iterate the number of active users, random subcarriers are generated
    % and added to the min no of subcarriers
    for i = 1 : numberOfUsers
        if((userStatus(:,j(i)) == 1) && (numberOfSamplesRemaining > 0))
            randomAllocation = randi(numberOfSamplesRemaining);
            userAllocation(:,j(i)) = userAllocation(:,j(i)) + randomAllocation;
            numberOfSamplesRemaining = numberOfSamplesRemaining - randomAllocation; 
        end
    end

end