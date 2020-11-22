enum CMD_PERMISSIONS
{
    EVERYONE,
    ADMIN
}

CMD <- {
    "Manager" : SqCmd.Manager(),
    "Commands" : {},

    function Register(commandName, params, paramsInfoArray, minParams, maxParams = null, authLevel = -1, prot = true, assoc = true) {
        if(maxParams == null)
            maxParams = paramsInfoArray.len() > 0 ? paramsInfoArray.len() : 0;
        Commands[commandName] <- Manager.Create(commandName, params, paramsInfoArray, minParams, maxParams, authLevel, prot, assoc);
        return Commands[commandName];
    }

    function Auth(player, command) {
        return (player.Data.permission_level >= command.Authority);
    }
}
CMD.Manager.BindAuth(this, CMD.Auth);

bindEvent("PlayerCommand", function(player, command) {
    CMD.Manager.Run(player, command);
});

/* ------------------------------------------------------------------------------------------------
 * General purpose error handler for a command manager.
 * Otherwise the player doesn't know why a command failed.
*/
CMD.Manager.BindFail(getroottable(), function(type, msg, payload) {
    // Retrieve the player that executed the command
    local player = CMD.Manager.Invoker;
    // See if the invoker even exists
    if (!player || typeof(player) != "SqPlayer")
    {
        return; // No one to report!
    }
    // Identify the error type
    switch (type)
    {
        // The command failed for unknown reasons
        case SqCmdErr.Unknown:
        {
            player.Message("Unable to execute the command for reasons unknown");
            player.Message("=> Please contact the developers");
        } break;
        // The command failed to execute because there was nothing to execute
        case SqCmdErr.EmptyCommand:
        {
            player.Message("Cannot execute an empty command");
        } break;
        // The command failed to execute because the command name was invalid after processing
        case SqCmdErr.InvalidCommand:
        {
            player.Message("The specified command name is invalid");
        } break;
        // The command failed to execute because there was a syntax error in the arguments
        case SqCmdErr.SyntaxError:
        {
            player.Message("There was a syntax error in argument: %d", payload);
        } break;
        // The command failed to execute because there was no such command
        case SqCmdErr.UnknownCommand:
        {
            player.Message("The specified command does not exist");
        } break;
        // The command failed to execute because the it's currently suspended
        case SqCmdErr.ListenerSuspended:
        {
            player.Message("The requested command is currently suspended");
        } break;
        // The command failed to execute because the invoker does not have the proper authority
        case SqCmdErr.InsufficientAuth:
        {
            player.Message("You don't have the proper authority to execute this command");
        } break;
        // The command failed to execute because there was no callback to handle the execution
        case SqCmdErr.MissingExecuter:
        {
            player.Message("The specified command is not being processed");
        } break;
        // The command was unable to execute because the argument limit was not reached
        case SqCmdErr.IncompleteArgs:
        {
            player.Message("The specified command requires at least %d arguments", payload);
        } break;
        // The command was unable to execute because the argument limit was exceeded
        case SqCmdErr.ExtraneousArgs:
        {
            player.Message("The specified command requires no more than %d arguments", payload);
        } break;
        // Command was unable to execute due to argument type mismatch
        case SqCmdErr.UnsupportedArg:
        {
            player.Message("Argument %d requires a different type than the one you specified", payload);
        } break;
        // The command arguments contained more data than the internal buffer can handle
        case SqCmdErr.BufferOverflow:
        {
            player.Message("An internal error occurred and the execution was aborted");
            player.Message("=> Please contact the developers");
        } break;
        // The command failed to complete execution due to a runtime exception
        case SqCmdErr.ExecutionFailed:
        {
            player.Message("The command failed to complete the execution properly");
            player.Message("=> Please contact the developers");
        } break;
        // The command completed the execution but returned a negative result
        case SqCmdErr.ExecutionAborted:
        {
            player.Message("The command execution was aborted and therefore had no effect");
        } break;
        // The post execution callback failed to execute due to a runtime exception
        case SqCmdErr.PostProcessingFailed:
        {
            player.Message("The command post-processing stage failed to complete properly");
            player.Message("=> Please contact the developers");
        } break;
        // The callback that was supposed to deal with the failure also failed due to a runtime exception
        case SqCmdErr.UnresolvedFailure:
        {
            player.Message("Unable to resolve the failures during command execution");
            player.Message("=> Please contact the developers");
        } break;
        // Something bad happened and no one knows what
        default:
            SqLog.Inf("Command failed to execute because [%s][%s]", msg, ""+payload);
    }
});