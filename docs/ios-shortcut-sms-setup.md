# iOS Shortcut — TNSTC SMS Automation Setup

This guide explains how to set up your iPhone Shortcuts automation so that
TNSTC (and SETC) SMS messages are automatically queued in Namma Wallet and
parsed the next time you open the app.

---

## How It Works

1. A TNSTC SMS arrives on your iPhone.
2. Your Shortcut fires automatically (via a Messaging automation trigger).
3. The Shortcut passes the SMS body to Namma Wallet via a URL scheme.
4. Namma Wallet stores the SMS in the shared App Group storage on your device.
5. The next time you open (or bring to foreground) Namma Wallet, it reads the
   queue, parses all pending SMS entries, saves the tickets, and shows you a
   notification confirming how many tickets were added.

> **No internet required.** The entire pipeline is on-device.

---

## Recommended Approach — "Add SMS to Namma Wallet" Action

This is the simplest and native approach. Namma Wallet provides a custom Shortcuts action that natively accepts the SMS text and saves it to the queue without launching the app.

### Step-by-step

1. Open the **Shortcuts** app → tap **Automation** tab → tap **+** (New Automation).
2. Choose trigger: **Message received** → Filter by sender containing `VK-TNSTC` 
   (repeat for `VK-SETCTC`, `JD-TNSTC`, etc. — create one automation per sender 
   pattern, or use "Message contains" with key terms like `PNR` or `TNSTC`).
3. Tap **New Blank Automation** → choose **Run Immediately** (no confirmation needed).
4. Tap **Add Action**.
5. Search for **Namma Wallet** and select the action named **Add SMS to Namma Wallet**.
6. Tap the faint `SMS Text` parameter in the action block, and select **Shortcut Input** (this passes the received message).
7. Tap **Done**.

> **Note:** Because this uses a native App Intent, the automation runs completely silently in the background. Namma Wallet will not momentarily open.

---

## Alternative Approach — URL Scheme (Fallback)

If you are on an older version of iOS (pre-iOS 16) that doesn't support App Intents, you can use the URL scheme.

1. Follow steps 1-3 above.
2. Add action: **Text** → assign `Shortcut Input` to a variable named `SMSBody`.
3. Add action: **URL** → type `nammawallet://enqueue?sms=` and append the `SMSBody` variable.
4. Add action: **Open URLs** → select the URL.
5. Tap **Done**. 
*(This will briefly flash the app open).*

---

## Alternative Approach — UserDefaults Write (Advanced / Scriptable)

If you use [Scriptable](https://scriptable.app), you can write directly to
the App Group `UserDefaults`, which avoids opening the app momentarily.

### Scriptable code

```javascript
// Save this as a script named "Queue TNSTC SMS" in Scriptable

const smsText = args.shortcutParameter;
const groupId = "group.com.nammaflutter.nammawallet";
const key = "sms_queue";

// Read existing queue
let existingData = Keychain.contains(groupId + "." + key)
  ? Keychain.get(groupId + "." + key)
  : "[]";
let queue = JSON.parse(existingData);
queue.push(smsText);

// Write back
Keychain.set(groupId + "." + key, JSON.stringify(queue));
```

> **Note:** `Keychain` in Scriptable does not share with `UserDefaults` App
> Groups directly. For production use, the **URL scheme approach above is
> recommended** as it uses the same native `UserDefaults` suite that Namma
> Wallet reads from.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| App opens briefly when Shortcut runs | Normal — the URL scheme triggers a brief app activation. The app returns to background automatically. |
| No notification after opening the app | Check notification permissions: **Settings → Namma Wallet → Notifications → Allow**. |
| Ticket not parsed correctly | Ensure the full SMS body is passed (not just a fragment). Test by manually sharing the SMS text to Namma Wallet via the Share Sheet. |
| Multiple tickets queued but only some parsed | Each SMS is processed independently. Check app logs via **Settings → Debug Logs** in Namma Wallet. |

---

## Supported SMS Senders

The following TNSTC/SETC SMS sender IDs are recognised by the parser:

- `VK-TNSTC`, `JD-TNSTC` — TNSTC booking confirmations
- `VK-SETCTC`, `JD-SETCTC` — SETC booking confirmations
- Update SMS (conductor details) from the same senders

> Messages from other senders will be queued but may not parse into tickets.
> They are cleared from the queue after one processing attempt.
