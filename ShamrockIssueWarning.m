function ShamrockIssueWarning(code, msg)
% Converts the code returned by the SDK into an error message
% ShamrockIssueWarning(code, msg)
% Arguments
%     code: the return code from the SDK
%     msg: custom message to tell user where warning occured.
% Returns:
%     None

  switch(code)
    case 20201
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_COMMUNICATION_ERROR [20201] during: ', msg], "Warning"));
    case 20202
      return
    case 20266
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_P1INVALID [20266] during: ', msg], "Warning"));
    case 20267
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_P2INVALID [20267] during: ', msg], "Warning"));
    case 20268
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_P3INVALID [20268] during: ', msg], "Warning"));
    case 20269
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_P4INVALID [20269] during: ', msg], "Warning"));
    case 20275
      uiwait(warndlg(['Shamrock SDK returned Warning: SHAMROCK_NOT_INITIALIZED [20275] during: ', msg], "Warning"));
    otherwise
      code_msg = sprintf('Shamrock SDK Returned Warning: UNKNOWN WARNING [%d] during: ',code);
      uiwait(warndlg([code_msg, msg], "Warning"));
  end
end
