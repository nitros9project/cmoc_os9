extern float atoff(const char *nptr);

float
atof(const char *str)
{
    char normalized[64];
    unsigned i = 0;

    if (str == 0)
        return 0.0f;

    for (; str[i] != '\0' && i + 1 < sizeof(normalized); ++i)
        normalized[i] = (str[i] == 'e' ? 'E' : str[i]);

    normalized[i] = '\0';

    if (str[i] == '\0')
        return atoff(normalized);

    return atoff(str);
}
