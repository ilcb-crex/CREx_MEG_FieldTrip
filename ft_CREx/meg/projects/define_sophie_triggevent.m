function triggevent = define_sophie_triggevent(Sevent)
nbcond = 1;
valstim = 5374;
eventyp = 'TRIGGER';
typ = {Sevent.type};
val = cell2mat({Sevent.value});

trigvalues = val(strcmp(typ,eventyp));

triggevent=struct('name',[],'value',[],'eventyp',repmat({eventyp},1,nbcond));


if ~isempty(find(trigvalues==valstim,1)) % On est dans un bon run 
    triggevent(1).name = 'Stim';
    triggevent(1).value = valstim;   
end
