function ShamrockIssueError(code)
% Converts the code returned by the SDK into an error message
% Checkuiwait(errordlg(code)
% Arguments
%     code: the return code from the SDK
% Returns:
%     None

  switch(code)
    case 20201
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_COMMUNICATION_ERROR [20201]', "Error"));
    case 20202
      return
    case 20266
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_P1INVALID [20266]', "Error"));
    case 20267
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_P2INVALID [20267]', "Error"));
    case 20268
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_P3INVALID [20268]', "Error"));
    case 20269
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_P4INVALID [20269]', "Error"));
    case 20275
      uiwait(errordlg('Shamrock SDK returned Error: SHAMROCK_NOT_INITIALIZED [20275]', "Error"));
      otherwise
        msg = sprintf('Shamrock SDK Returned Error: UNKNOWN ERROR [%d]',code);
      uiwait(warndlg(msg, "Warning"));
  end
end
