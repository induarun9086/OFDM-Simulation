function y=qamdemap(x)

% Get the real and Imaginary part from the sequence

xReal= real(x);
xImag= imag(x);

% compare the real values to the threshold 
%and get the binary equivalent
if xReal<0
    if abs(xReal)<2
        xDecReal=1;
    else
         xDecReal=0;
    end
    
else
    
     if abs(xReal)<2
        xDecReal=3;
    else
         xDecReal=2;
    end
end

% compare the Imaginary values to the threshold 
% and get the binary equivalent
if xImag<0
    if abs(xImag)<2
        xDecImag=1;
    else
         xDecImag=0;
    end
    
else
    
     if abs(xImag)<2
        xDecImag=3;
    else
         xDecImag=2;
    end
end


% convert the values to decimal
y=xDecReal*4+xDecImag;


end