function  IFFTBlock()
    x = 1 : 1 : 256;
    
    %Find length of the input
    N = length(x);
    
    %IIFFT(x) = 1/N * conjugate(fft(conjugate(x))
    
    %conjugate the input 
    cx = conj(x);
    
    %compute fft for the conjugated input
    y = fftBlock(cx);
    
    %conjugate the output of the fft block and 
    %divide it by length of the input
    cy = conj(y)/N;
         
end

function y = fftBlock(x)

    %Calculate length of the input
    N  = length(x);
    
    % twiddle factor index
    k = 0:(N/2)-1;  
    
    % compute the twiddle factor
    w = exp((-1i*2*pi*k)/N);
    
    %initialise the temp array where 
    %results from each step of fft is stored
    temp = zeros(1,N);
    
    % calculate the reversed bits' index and 
    % store it in an array
    index = 0 : N-1;
    revIndex = bitrevorder(index) + 1;
   
    % number of steps needed is ln(N)
    numberOfSteps = log(N) / log (2);
   
    % loop through each step
    for s = 1 : numberOfSteps
        i = 1;
        % loop through number of butterfly groups in each step
        for j  = 1  : 2^(numberOfSteps-s)
            % Initialise index for w
            windex = 1;
            % loop through number of butterflies in each group
            for p = 1 : 2 ^ (s-1)
                
                % for the first butterfly group fft should be done with
                % reversed bit order
                if(s == 1)
                    x1 = x(revIndex(i));
                    x2 = w(windex)*x(revIndex(i+1));  
                else
                    % For other cases fft could be computed with the
                    % intermediate results which is stored in x
                    x1 = x(i+(p-1));
                    x2 = w(windex)*x(i+(p-1)+2^(s-1));
                end
                
                % butterfly operations done
                temp(i+(p-1)) =  x1 + x2;
                temp(i+(p-1)+2^(s-1)) = x1 - x2;
                % Increment the index of w as 2^(numberOfSteps-s) 
                % for 8-bit example [0,4] for 2nd step
                % [0,2,4] in the 3rd step and so on...
                windex = windex + (2^(numberOfSteps-s));
            end
            %Increment i so that we move to the next butterfly group
            i = i+2^s;   
        end
        %Store the temp results to x 
        %which will we used for further computations
        x = temp;
        
    end 
    %copy end result to output array - y
    y = x;
end