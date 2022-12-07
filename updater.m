function [] = updater(obj, event, app)
    app.time = app.time + 1;
    time = string(duration(0,0,app.time));
    app.TimeTakenEditField.Value = time;
end

