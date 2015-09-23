function var = loadvar(pathmat,varname)
    try
        matin = load(pathmat, varname);
        fn = fieldnames(matin);
        var = matin.(fn{1});
    % Ajouter message Warning si plusieurs variables varname trouvees dans
    % pathmat
    catch
        disp(['Impossible to load variable ',varname,' from'])
        disp(pathmat)
        var = [];
    end
end

