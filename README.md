# keymaster

Looking past the corny Ghostbusters reference, this is a simple platform interface for the Apple keychain.

## Example
Utilize the static class to interact with the Apple keychain.

Add to `pubspec.yaml`:
```yaml
keymaster:
    git:
      url: https://github.com/StonePack/keymaster.git
      ref: v0.0.1
```

Use
```dart
Keymaster.set('infoKey', 'some_secure_info');

Keymaster.fetch('infoKey');

Keymaster.delete('infoKey');
```
