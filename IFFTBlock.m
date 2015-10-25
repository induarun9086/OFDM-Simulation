function  IFFTBlock()
    x = 1 : 1 : 256; 
    y = fft(x);
    N  = length(x);
    
    k = 0:(N/2)-1;  
    w = exp((-1i*2*pi*k)/N);
    
    temp = zeros(1,N);
    
    index = 0 : N-1;
    
    revIndex = bitrevorder(index) + 1;
   
    numberOfSteps = log(N) / log (2);
   
    for s = 1 : numberOfSteps
        i = 1;
        for j  = 1  : 2^(numberOfSteps-s)
            windex = 1;
            for p = 1 : 2 ^ (s-1)
                
                if(s == 1)
                    x1 = x(revIndex(i));
                    x2 = w(windex)*x(revIndex(i+1));  
                else
                    x1 = x(i+(p-1));
                    x2 = w(windex)*x(i+(p-1)+2^(s-1));
                end
                display(windex);
                temp(i+(p-1)) =  x1 + x2;
                temp(i+(p-1)+2^(s-1)) = x1 - x2;
                windex = windex + (2^(numberOfSteps-s));
            end
            i = i+2^s;   
        end
        x = temp;
        
    end     
    display(y-x);
    subplot(1, 2, 1), plot(x);
    subplot(1, 2, 2), plot(y);
end