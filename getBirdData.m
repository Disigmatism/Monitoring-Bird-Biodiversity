function [birdData] = getBirdData(dataTable, paddingOption)

% count = 0;
birdData = repmat(BirdData,1,height(dataTable));
for i= 1:height(dataTable)
    
    birdObject = BirdData;
    birdObject.ID = i;
    filename = dataTable(i,"filename").Variables;
    x1 = dataTable(i,"x1").Variables;
    x2 = dataTable(i,"x2").Variables;
    code = dataTable(i,"birdcode").Variables;
    birdObject.BirdCode = code;
    birdObject.BirdCodeID = birdObject.setBirdCodeID(code);    
    [y,Fs] = audioread(filename);


    fixedSeconds = 144000; %48000 * (number of Seconds)
    sampleStart = round(round(x1,2)*Fs);
    sampleEnd = round(round(x2,2)*Fs);
    if(sampleStart < 1) 
        sampleStart = 1;
        sampleEnd = sampleEnd +1;
    end
    if(sampleEnd > length(y))
        sampleEnd = length(y);
    end
    if(paddingOption == "Pad")
        y = y(sampleStart : sampleEnd);
        sigma= mean(abs(y));
        mu = 0;
        s = sigma*randn(fixedSeconds - length(y),1)+mu;
        mid = randi([1 length(s)]);
        z = cat(1, s(1 : mid),y,s(mid : length(s)));
    else
        rangeStart = sampleEnd - fixedSeconds;
        rangeEnd = sampleStart;
        range = randi([rangeStart  ,rangeEnd]);
        if(range > 0 && range + fixedSeconds < length(y))
            z = y(range : range+fixedSeconds); 
        end
        if(range + fixedSeconds > length(y))
            z = y(sampleEnd - fixedSeconds : sampleEnd); end
        if(range < 0)
            range = randi([1,sampleStart]);
            z = y(range : range+fixedSeconds+1); 
        end
    end
    
    
    [~,~,~,P] = spectrogram(z,1024,512,1024,Fs,'yaxis');
    
   
    arraySize = size(P,1) * size(P,2);
    P = reshape(P,[arraySize, 1]);
    spectogramVector = P;
    birdObject.Spectogram = spectogramVector;
    
   
    
    extractor = audioFeatureExtractor(...,
     "SampleRate",Fs,...
     "mfcc",true);
    setExtractorParams(extractor,"mfcc","NumCoeffs",20);
    features = extract(extractor,z);
    
    arraySize = size(features,1) * size(features,2);
    featureVector = reshape(features,[arraySize, 1]);
    birdObject.Features = featureVector;
    birdData(i) = birdObject;
    
end
end
