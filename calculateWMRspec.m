function v1 = calculateWMRspec(spec,ramanPk)
%calculate WMRS with PCA
if nargin<2 
    ramanPk = 123;
end
if isempty(ramanPk)
    ramanPk = 123;
end
% cosmic ray treatment new method for each spectrum; presume that
% cosmic ray will not occurpy more than 1 pixel. all cosmic ray
% occupy more than 2 pixels will not be removed correctly.
for mm = 1:size(spec,2)
    spec = double(spec);
    [pks,locs] = findpeaks(double(spec(:,mm))); %find local peaks
    for pp = 1:length(pks)
        if locs(pp)<3
            continue;
        elseif locs(pp)>size(spec(:,mm),1)-2
            continue;
        end
        locPk = spec(locs(pp)-2:locs(pp)+2,mm);
        meankk = mean(locPk([1:2 4:5]));
        mmkk = abs(locPk([1:2 4:5])-meankk);
        avpk = mean(mmkk);
        stdpk = std(mmkk);
        for kk = 1:length(locPk)
            if (locPk(kk)-meankk) > avpk+5*stdpk
                spec(locs(pp)-3+kk,mm)=spec(locs(pp)-3+kk-1,mm); %set by nearby previous value
            end
        end
    end
end
normfactor = double(repmat(sum(spec),size(spec,1),1));
spec = spec./normfactor; %normalized by total energy;
spec = double(spec');

% cosmic ray treatment with all spectrum;
sppp = spec;
for idd = 1:size(spec,1)
    spec(idd,:)=circshift(spec(idd,:),[0 -(idd-1)]);  %idd - 1 depends on the modulation range; move the spectra;
end
ss=sort(spec,1);
ssm1=ss(1:end-1,1:end-idd);
mmd = mean(ssm1);
[row,col,ind] = find((spec(:,1:end-idd)-repmat(mmd,size(spec,1),1))>repmat(3*std(ssm1),size(spec,1),1));
%[row,col]=ind2sub(size(spec),ind);
for idd = 1:length(row)
    sppp(row(idd),col(idd)+row(idd)-1) = mmd(col(idd));    %replace cosmic ray data point with the mean value;
end
spec = sppp;

%PCA
spec0=spec-repmat(mean(spec),[size(spec,1),1]);%spec0=spec-repmat(mean(spec')',[1,size(spec,2)]);
[v,d]=eig(cov(spec0'));
v1=spec0'*v(:,end);
v1=v1*sign(v1(ramanPk))*mean(normfactor(1,:));
end