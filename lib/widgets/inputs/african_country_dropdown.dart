import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'dropdown_input.dart';

class AfricanCountry {
  final String name;
  final String code;
  final String flag;

  const AfricanCountry({
    required this.name,
    required this.code,
    required this.flag,
  });
}

const List<AfricanCountry> africanCountries = [
  AfricanCountry(name: 'Algeria', code: '+213', flag: '🇩🇿'),
  AfricanCountry(name: 'Angola', code: '+244', flag: '🇦🇴'),
  AfricanCountry(name: 'Benin', code: '+229', flag: '🇧🇯'),
  AfricanCountry(name: 'Botswana', code: '+267', flag: '🇧🇼'),
  AfricanCountry(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
  AfricanCountry(name: 'Burundi', code: '+257', flag: '🇧🇮'),
  AfricanCountry(name: 'Cameroon', code: '+237', flag: '🇨🇲'),
  AfricanCountry(name: 'Cape Verde', code: '+238', flag: '🇨🇻'),
  AfricanCountry(name: 'Central African Republic', code: '+236', flag: '🇨🇫'),
  AfricanCountry(name: 'Chad', code: '+235', flag: '🇹🇩'),
  AfricanCountry(name: 'Comoros', code: '+269', flag: '🇰🇲'),
  AfricanCountry(name: 'Congo (Brazzaville)', code: '+242', flag: '🇨🇬'),
  AfricanCountry(name: 'Congo (Kinshasa)', code: '+243', flag: '🇨🇩'),
  AfricanCountry(name: 'Djibouti', code: '+253', flag: '🇩🇯'),
  AfricanCountry(name: 'Egypt', code: '+20', flag: '🇪🇬'),
  AfricanCountry(name: 'Equatorial Guinea', code: '+240', flag: '🇬🇶'),
  AfricanCountry(name: 'Eritrea', code: '+291', flag: '🇪🇷'),
  AfricanCountry(name: 'Eswatini', code: '+268', flag: '🇸🇿'),
  AfricanCountry(name: 'Ethiopia', code: '+251', flag: '🇪🇹'),
  AfricanCountry(name: 'Gabon', code: '+241', flag: '🇬🇦'),
  AfricanCountry(name: 'Gambia', code: '+220', flag: '🇬🇲'),
  AfricanCountry(name: 'Ghana', code: '+233', flag: '🇬🇭'),
  AfricanCountry(name: 'Guinea', code: '+224', flag: '🇬🇳'),
  AfricanCountry(name: 'Guinea-Bissau', code: '+245', flag: '🇬🇼'),
  AfricanCountry(name: 'Ivory Coast', code: '+225', flag: '🇨🇮'),
  AfricanCountry(name: 'Kenya', code: '+254', flag: '🇰🇪'),
  AfricanCountry(name: 'Lesotho', code: '+266', flag: '🇱🇸'),
  AfricanCountry(name: 'Liberia', code: '+231', flag: '🇱🇷'),
  AfricanCountry(name: 'Libya', code: '+218', flag: '🇱🇾'),
  AfricanCountry(name: 'Madagascar', code: '+261', flag: '🇲🇬'),
  AfricanCountry(name: 'Malawi', code: '+265', flag: '🇲🇼'),
  AfricanCountry(name: 'Mali', code: '+223', flag: '🇲🇱'),
  AfricanCountry(name: 'Mauritania', code: '+222', flag: '🇲🇷'),
  AfricanCountry(name: 'Mauritius', code: '+230', flag: '🇲🇺'),
  AfricanCountry(name: 'Morocco', code: '+212', flag: '🇲🇦'),
  AfricanCountry(name: 'Mozambique', code: '+258', flag: '🇲🇿'),
  AfricanCountry(name: 'Namibia', code: '+264', flag: '🇳🇦'),
  AfricanCountry(name: 'Niger', code: '+227', flag: '🇳🇪'),
  AfricanCountry(name: 'Nigeria', code: '+234', flag: '🇳🇬'),
  AfricanCountry(name: 'Rwanda', code: '+250', flag: '🇷🇼'),
  AfricanCountry(name: 'Sao Tome and Principe', code: '+239', flag: '🇸🇹'),
  AfricanCountry(name: 'Senegal', code: '+221', flag: '🇸🇳'),
  AfricanCountry(name: 'Seychelles', code: '+248', flag: '🇸🇨'),
  AfricanCountry(name: 'Sierra Leone', code: '+232', flag: '🇸🇱'),
  AfricanCountry(name: 'Somalia', code: '+252', flag: '🇸🇴'),
  AfricanCountry(name: 'South Africa', code: '+27', flag: '🇿🇦'),
  AfricanCountry(name: 'South Sudan', code: '+211', flag: '🇸🇸'),
  AfricanCountry(name: 'Sudan', code: '+249', flag: '🇸🇩'),
  AfricanCountry(name: 'Tanzania', code: '+255', flag: '🇹🇿'),
  AfricanCountry(name: 'Togo', code: '+228', flag: '🇹🇬'),
  AfricanCountry(name: 'Tunisia', code: '+216', flag: '🇹🇳'),
  AfricanCountry(name: 'Uganda', code: '+256', flag: '🇺🇬'),
  AfricanCountry(name: 'Zambia', code: '+260', flag: '🇿🇲'),
  AfricanCountry(name: 'Zimbabwe', code: '+263', flag: '🇿🇼'),
];

class AfricanCountryCodeDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?>? onChanged;

  const AfricanCountryCodeDropdown({
    super.key,
    this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    final itemStyle = AppTypography.getTextStyle(
      context,
      AppTextType.tiny,
      color: themeExtension.textInputColor,
    );

    return SizedBox(
      width: 124,
      child: CustomDropdownField<String>(
        value: value,
        onChanged: onChanged,
        textType: AppTextType.tiny,
        items: [
          for (final country in africanCountries)
            DropdownMenuItem<String>(
              value: country.code,
              child: Text(
                '${country.flag}  ${country.code}',
                style: itemStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}