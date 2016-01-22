function triggevent = define_adys_triggevent(Sevent)

nbcond = 6;
eventyp = 'TRIGGER';
resptyp = 'RESPONSE';
typ = {Sevent.type};
val = cell2mat({Sevent.value});

trigvalues = val(strcmp(typ,eventyp));

triggevent = struct('name',[],'value',[],'rightresp',[],...
    'eventyp',repmat({eventyp},1,nbcond),...
    'resptyp',repmat({resptyp},1,nbcond));

iod=512;

if ~isempty(find(trigvalues==50 + iod,1)) % On est dans un bon run (et pas un BaPa par exemple)
    
    triggevent(1).name = 'Morpho';
    triggevent(2).name = 'Ortho';
    triggevent(3).name = 'Seman';
    triggevent(4).name = 'NonR';  
    triggevent(5).name = 'Pseudo'; 
    triggevent(6).name = 'AllWords'; 

    triggevent(1).value = 10 + iod;
    triggevent(2).value = 20 + iod;
    triggevent(3).value = 30 + iod;
    triggevent(4).value = 40 + iod;
    triggevent(5).value = 50 + iod;
    triggevent(6).value = [10 20 30 40] + iod;
    
    triggevent(1).rightresp = 256;
    triggevent(2).rightresp = 256;
    triggevent(3).rightresp = 256;
    triggevent(4).rightresp = 256;
    triggevent(5).rightresp = 128;
    triggevent(6).rightresp = 256;    
end
