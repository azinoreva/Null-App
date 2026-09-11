# `lib/widgets/inputs` — Input Components

| File | Purpose |
|---|---|
| `input_field.dart` | `CustomInputField` — themed `TextField` wrapper: configurable controller, hint text, `AppTextType`-driven styling, `onChanged`, `obscureText`, `maxLines`. Uses the app's shared 4px-radius `darkSlate`-bordered decoration with a transparent fill. Used for phone and password inputs on the Login and Signup screens. |
| `dropdown_input.dart` | `CustomDropdownField<T>` — themed generic `DropdownButtonFormField<T>` wrapper with the same 4px-radius dark-slate border, transparent fill, hint support, and a down-arrow icon. Used on `SignupScreen` for the phone country-code selector (+1 / +44 / +234). |