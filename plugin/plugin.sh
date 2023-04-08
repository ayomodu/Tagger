function get_semantic_version() {
  # Check if a file exists and read its contents
  if [[ -e "csproj" ]]; then
    version=$(grep -oP '<Version>\K.*(?=</Version>)' csproj)
  elif [[ -e "package.json" ]]; then
    version=$(grep -oP '"version": "\K.*?(?=")' package.json)
  elif [[ -e "pom.xml" ]]; then
    version=$(grep -oP '<version>\K.*(?=</version>)' pom.xml)
  else
    echo "Error: could not find project configuration file"
    return 1
  fi

  # Check if the version matches the semantic versioning format
  if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$ ]]; then
    echo "$version"
  else
    echo "Error: version is not in semantic versioning format"
    return 1
  fi
}
The function first checks for the existence of the three most common project configuration files: csproj, package.json, and pom.xml. If any of these files are found, it uses grep to extract the version number from the file. If none of these files are found, an error message is displayed and the function returns with an error code.

Once the version number is extracted, the function checks whether it matches the semantic versioning format using a regular expression. If the version number is in the correct format, it is returned by the function. Otherwise, an error message is displayed and the function returns with an error code.

Note that this function assumes that the configuration files are located in the current working directory. If your files are located elsewhere, you will need to modify the paths in the function accordingly.





