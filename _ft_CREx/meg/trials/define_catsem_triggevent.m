function triggevent = define_catsem_triggevent(Sevent)

eventyp = 'TRIGGER';
typ = {Sevent.type};
val = cell2mat({Sevent.value});

trigvalues = val(strcmp(typ,eventyp));

triggevent=struct('name',[],'value',[],'rightresp',[],'eventyp',repmat({eventyp},1,4));

if ~isempty(find(trigvalues==(130+1024),1)) || ~isempty(find(trigvalues==(130),1))
    triggevent(1).name = 'Audio_Corps';
    triggevent(2).name = 'Audio_RegHF';
    triggevent(3).name = 'Audio_RegLF';
    triggevent(4).name = 'Audio_IrregHF';
    triggevent(5).name = 'Audio_IrregLF';
    if ~isempty(find(trigvalues==(130+1024),1))
        triggevent(1).value = 130+1024;
        triggevent(2).value = [(1:2:29)+4095  2:2:30]+1024;
        triggevent(3).value = [(31:2:59)+4095 32:2:60]+1024;
        triggevent(4).value = [(61:2:89)+4095 62:2:90]+1024;
        triggevent(5).value = [(91:2:119)+4095 92:2:120]+1024; 
    else
        triggevent(1).value = 130;
        triggevent(2).value = [(1:2:29)+4095  2:2:30];
        triggevent(3).value = [(31:2:59)+4095 32:2:60];
        triggevent(4).value = [(61:2:89)+4095 62:2:90];
        triggevent(5).value = [(91:2:119)+4095 92:2:120];       
    end
    triggevent(5).eventyp = eventyp;
end

if ~isempty(find(trigvalues==592,1))
    triggevent(1).name = 'Visu_Corps';
    triggevent(2).name = 'Visu_RegHF';
    triggevent(3).name = 'Visu_RegLF';
    triggevent(4).name = 'Visu_IrregLF';  
    
    iod=512;
    triggevent(1).value = 80+iod;
    triggevent(2).value = 24+iod;
    triggevent(3).value = 22+iod;
    triggevent(4).value = 20+iod;
end