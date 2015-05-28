function triggevent = define_default_triggevent(Sevent)

eventyp = 'TRIGGER';
typ = {Sevent.type};
val = cell2mat({Sevent.value});

trigvalues = val(strcmp(typ,eventyp));

triggevent=struct('name',[],'value',[],'eventyp',eventyp);


triggevent.name = 'AllTriggers';
triggevent.value = trigvalues;


