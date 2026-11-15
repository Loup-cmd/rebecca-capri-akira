pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam

// Verrouillage de session (WlSessionLock) et authentification PAM.
Singleton {
    id: root

    property bool locked: false
    property bool failed: false
    property string message: ""
    property string secret: ""
    readonly property bool checking: pam.active

    signal shake()

    function lock() {
        if (locked) return;
        failed = false;
        message = "";
        Ui.closeAll();
        locked = true;
    }

    function submit(password) {
        if (!locked || pam.active || password === "") return;
        failed = false;
        message = "";
        secret = password;
        pam.start();
    }

    PamContext {
        id: pam
        config: "login"

        onPamMessage: {
            if (responseRequired) {
                respond(root.secret);
                root.secret = "";
            }
        }

        onCompleted: result => {
            root.secret = "";
            if (result === PamResult.Success) {
                root.locked = false;
                return;
            }
            root.failed = true;
            root.message = result === PamResult.MaxTries ? "TROP D'ESSAIS" : "ACCÈS REFUSÉ";
            root.shake();
        }

        onError: {
            root.secret = "";
            root.failed = true;
            root.message = "ERREUR D'AUTHENTIFICATION";
            root.shake();
        }
    }

    IpcHandler {
        target: "lock"
        function lock(): void { root.lock(); }
        function isLocked(): bool { return root.locked; }
    }
}
