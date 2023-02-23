function ShamrockIssueWarning(code)
% Converts the code returned by the SDK into an error message
% Checkuiwait(warndlg(code)
% Arguments
%     code: the return code from the SDK
% Returns:
%     None

  switch(code)
    case 20201
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_COMMUNICATION_ERROR [20201]', "Warning"));
    case 20202
      return
    case 20266
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_P1INVALID [20266]', "Warning"));
    case 20267
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_P2INVALID [20267]', "Warning"));
    case 20268
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_P3INVALID [20268]', "Warning"));
    case 20269
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_P4INVALID [20269]', "Warning"));
    case 20275
      uiwait(warndlg('Shamrock SDK returned Warning: SHAMROCK_NOT_INITIALIZED [20275]', "Warning"));
      otherwise
        msg = sprintf('Shamrock SDK Returned Warning: UNKNOWN ERROR [%d]',code);
      uiwait(warndlg(msg, "Warning"));
  end
end
