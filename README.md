# keymaster

Simple platform interface for the Apple keychain.

## Example
Utilize the simple static class to interact with the Apple keychain.

```dart
Keymaster.set('infoKey', 'some_secure_info');

Keymaster.fetch('infoKey');

Keymaster.delete('infoKey');
```

