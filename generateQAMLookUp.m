function qamOutput = generateQAMLookUp

    M=16; % 16 Bit QAM
    q=log2(M);
    
    %QAM bit mapping generation
    realVal = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
    realVal=transpose(realVal);
    imagVal = [-(2*sqrt(M)/2-1):2:-1 1:2:2*sqrt(M)/2-1];
    imagVal=transpose(imagVal);
       x=0:M-1;
      xbin=dec2bin(x);
      %real
      xrealdec=bin2dec(xbin(:, 1:q/2));
      xgrayreal = bitxor(xrealdec,floor(xrealdec/2));
      %imag
      ximagdec=bin2dec(xbin(:, q/2+1:q));
      xgrayimag = bitxor(ximagdec,floor(ximagdec/2));

      modReal=realVal(xgrayreal+1);
      modImag=imagVal(xgrayimag+1);
      qamOutput=modReal+1j*modImag;

end