function triggevent = define_bapaseeg_triggevent(Sevent) %#ok

eventyp = 'Stimulus';


triggevent = struct('name',[],'value',[],'eventyp',repmat({eventyp},1,2));

    
triggevent(1).name = 'Ba';
triggevent(2).name = 'Pa';

triggevent(1).value = 'S  4';
triggevent(2).value = 'S  2';

