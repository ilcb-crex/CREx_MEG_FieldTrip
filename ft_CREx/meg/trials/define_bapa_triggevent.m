function triggevent = define_bapa_triggevent(Sevent)

eventyp = 'TRIGGER';
typ = {Sevent.type};
val = cell2mat({Sevent.value});

trigvalues = val(strcmp(typ,eventyp));

triggevent=struct('name',[],'value',[],'eventyp',repmat({eventyp},1,2));



if ~isempty(find(trigvalues==2,1)) % On est dans un bon run (et pas un BaPa par exemple)
    
    triggevent(1).name = 'Ba';
    triggevent(2).name = 'Pa';

    triggevent(1).value = 4;
    triggevent(2).value = 2;
end
