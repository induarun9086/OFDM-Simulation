function  OFDM_Simulation(~,~,handles)
  % Initialise the global variables
  global count;
  global axesHandleArray;
  global textHandleArray;
  global qamOutput;
  global userAllocation;
  global imageWriteIndex;
  global imageReadIndex; 
  global userStatus;
  global rcvdImage;
  global imageData;
  
  % Assign values for number of users and number of input samples
  numberOfUsers = 10;
  numberOfInputSamples = 200;  
  
  % if count == 0 there is no active users
  if(count == 0)
    saveHandlesInArray(handles,numberOfUsers);
  end

  % schedule subcarriers for active users
  if(mod(count,20) == 0)
    userAllocation = UserScheduling(numberOfUsers,numberOfInputSamples,5);
  end
 
  count  = count + 1;
  msg = {int2str(count)};
  set(handles.edit21,'String',msg);
  
  % get data for the user according to the number of users
  [inBuffer, transferDone] = getUserData(numberOfUsers,numberOfInputSamples);
     
  % Do modulation and pad 56 zeros 
  qamOut=qamOutput(inBuffer+1);
  qamOut=transpose(qamOut);
  qamPad =[qamOut zeros(1, 256- numberOfInputSamples)];

  % Apply IFFT 
  ifft_output=ifft_recursive(qamPad);
 
  snr = get(handles.SNR_Slider, 'value');
  set(handles.snrValue, 'String', strcat(int2str(snr), ' dB'));
  
  % skip noise for header as it may corrupt the image
  headerPresent = 0;
  for i = 1 : numberOfUsers
      if((userStatus(:,i) == 1) && (imageReadIndex(i) < 300))
          headerPresent = 1;
      end
  end
  
  % If not apply noise according to tha user given SNR
  if(headerPresent == 0)
    awgnOutput = awgn(ifft_output,snr); 
  else
    awgnOutput = ifft_output;
  end
  
  % From here the receiver part starts
  % FFT the received output
  fft_output=fft_recursive(awgnOutput);
  output=fft_output(1:1:200);

  % Demodulate the result from FFT block
  qamdeout=qamdemod(output);

  % write the ouput image
  writeOutputData(numberOfUsers,qamdeout);
  
  % Show all the images in the axes in the GUI
  for i = 1 : numberOfUsers
    if(((imageWriteIndex(i) > 1000) && (mod(count,20) == 0)) || (transferDone(:,i) == 1))
        I = imread(strcat('Receivedpicture_',int2str(i), '.bmp'));
        imshow(I,'Parent',axesHandleArray(:,i));
    end

    % Compute the Data rate
    dataRate = 0;
    if(userStatus(:,i) == 1)
        dataRate = (userAllocation(:,i) * 4)/(0.000067);
    end
    
    % Compute the BER
    ber = 0;
    imageSize = size(imageData, 1);
    if((userStatus(:,i) == 1) && (imageWriteIndex(i) > 1) && (imageWriteIndex(i) < imageSize))
        currentFrameStart = 1 + imageWriteIndex(i) - userAllocation(:, i);
        currentFrameStop  = imageWriteIndex(i);
        diff = rcvdImage(i, currentFrameStart:currentFrameStop) - (imageData(currentFrameStart:currentFrameStop, 1))';
        ber  = (nnz(diff) / (currentFrameStop - currentFrameStart)) * 100.0;
    end
    
    set(textHandleArray(:,i), 'String' , strcat('DR: ', int2str(dataRate/1000), ' kbps', ' BER: ', int2str(ber), ' %'));
    
  end  
  
end
 
  
  function [inBuffer, transferDone] = getUserData(numberOfUsers,numberOfInputSamples)
    global userStatus;
    global imageData;
    global imageReadIndex; 
    global userHandleArray;
    global imageWriteIndex;
    global userAllocation;
    
    inBuffer  = zeros(numberOfInputSamples,1);
    transferDone = zeros(1, numberOfUsers);
    
    startCopyIndex = 1; 
    
    for i = 1 : numberOfUsers
        % If the user is allocated subcarriers, get data for the users
        if(userAllocation(:,i) > 0)
            if (imageReadIndex(i) >= size(imageData,1))
                userStatus(:,i) = 0;
                set(userHandleArray(:,i),'String','Start');
                imageReadIndex(:,i) = 0;
                imageWriteIndex(:,i) = 0;
                userAllocation(:,i) = 0;
                transferDone(:,i) = 1;
            else
                readEndIndex = imageReadIndex(i) + userAllocation(:,i);

                if(readEndIndex > size(imageData,1))
                    readEndIndex = size(imageData,1);
                end

                l = readEndIndex - imageReadIndex(i);
                stopCopyIndex = startCopyIndex + l - 1;
                
                inBuffer(startCopyIndex : stopCopyIndex , :) = imageData(imageReadIndex(i) + 1 : readEndIndex, 1);

                imageReadIndex(i)  = imageReadIndex(i) + l;
                startCopyIndex = stopCopyIndex + 1;
            end
        end
    end
  end
  
  function writeOutputData(numberOfUsers,qamdeout)
     global imageWriteIndex;
     global rcvdImage;
     global userAllocation;
     
     startCopyIndex = 1;
     
     for i = 1 : numberOfUsers
         % If the transmitter has transmitted data, write to the output
         % accordingly
         if(userAllocation(:,i) > 0)
             writeEndIndex = imageWriteIndex(i) + userAllocation(:,i);
             
             l = writeEndIndex - imageWriteIndex(i);
             stopCopyIndex = startCopyIndex + l - 1;
             
             rcvdImage(i,imageWriteIndex(i) + 1 :writeEndIndex) = qamdeout(:,startCopyIndex:stopCopyIndex);
            
             imageWriteIndex(i) = writeEndIndex;
             fid2=fopen(strcat('Receivedpicture_',int2str(i), '.bmp'),'w','b');   
             fwrite(fid2,rcvdImage(i, 1:imageWriteIndex(i)), 'ubit4');    
             fclose(fid2);
             
             startCopyIndex = stopCopyIndex + 1;
         end
      end
  end
  
  function saveHandlesInArray(handles,numberOfUsers)
     global axesHandleArray;
     global userHandleArray;
     global textHandleArray;
     
     % GUI handles for axes for displaying images
     
     axesHandleArray = zeros(1,numberOfUsers);
     userHandleArray = zeros(1,numberOfUsers);
     textHandleArray = zeros(1,numberOfUsers);
     
     axesHandleArray(:,1) = handles.axes4;
     axesHandleArray(:,2) = handles.axes12;
     axesHandleArray(:,3) = handles.axes13;
     axesHandleArray(:,4) = handles.axes14;
     axesHandleArray(:,5) = handles.axes15;
     axesHandleArray(:,6) = handles.axes16;
     axesHandleArray(:,7) = handles.axes17;
     axesHandleArray(:,8) = handles.axes18;
     axesHandleArray(:,9) = handles.axes19;
     axesHandleArray(:,10)= handles.axes20;
     
     textHandleArray(:,1) = handles.edit4;
     textHandleArray(:,2) = handles.edit12;
     textHandleArray(:,3) = handles.edit13;
     textHandleArray(:,4) = handles.edit14;
     textHandleArray(:,5) = handles.edit15;
     textHandleArray(:,6) = handles.edit16;
     textHandleArray(:,7) = handles.edit17;
     textHandleArray(:,8) = handles.edit18;
     textHandleArray(:,9) = handles.edit19;
     textHandleArray(:,10) = handles.edit20;
     
     userHandleArray(:,1) = handles.User1;
     userHandleArray(:,2) = handles.User2;
     userHandleArray(:,3) = handles.User3;
     userHandleArray(:,4) = handles.User4;
     userHandleArray(:,5) = handles.User5;
     userHandleArray(:,6) = handles.User6;
     userHandleArray(:,7) = handles.User7;
     userHandleArray(:,8) = handles.User8;
     userHandleArray(:,9) = handles.User9;
     userHandleArray(:,10) = handles.User10;
  end