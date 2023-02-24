function ShamrockIssueError(code, msg)
% Converts the code returned by the SDK into an error message
% ShamrockIssueError(code, msg)
% Arguments
%     code: the return code from the SDK
%     msg: custom message to tell user where error occured.
% Returns:
%     None

  switch(code)
    case 20201
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_COMMUNICATION_ERROR [20201] during: ', msg], "Error"));
    case 20202
      return
    case 20266
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_P1INVALID [20266] during: ', msg], "Error"));
    case 20267
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_P2INVALID [20267] during: ', msg], "Error"));
    case 20268
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_P3INVALID [20268] during: ', msg], "Error"));
    case 20269
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_P4INVALID [20269] during: ', msg], "Error"));
    case 20275
      uiwait(errordlg(['Shamrock SDK returned Error: SHAMROCK_NOT_INITIALIZED [20275] during: ', msg], "Error"));
    otherwise
      code_msg = sprintf('Shamrock SDK Returned Error: UNKNOWN ERROR [%d] during: ',code);
      uiwait(errordlg([code_msg, msg], "Warning"));
  end
end
