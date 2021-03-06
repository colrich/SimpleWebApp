#!/bin/bash

baseName="pcf-demo"

inputDir=     # required
outputDir=    # required
versionFile=  # optional
inputManifest=  # optional
artifactId=  # optional
packaging= # optional

#
hostnameAWS=$CF_MANIFEST_HOST_AWS # default to env variable from pipeline


while [ $# -gt 0 ]; do
  case $1 in
    -i | --input-dir )
      inputDir=$2
      shift
      ;;
    -o | --output-dir )
      outputDir=$2
      shift
      ;;
    -v | --version-file )
      versionFile=$2
      shift
      ;;
    -f | --input-manifest )
      inputManifest=$2
      shift
      ;;
    -a | --artifactId )
      artifactId=$2
      shift
      ;;
    -p | --packaging )
      packaging=$2
      shift
      ;;
    * )
      echo "Unrecognized option: $1" 1>&2
      exit 1
      ;;
  esac
  shift
done

if [ ! -d "$inputDir" ]; then
  echo "missing input directory!"
  exit 1
fi

if [ ! -d "$outputDir" ]; then
  echo "missing output directory!"
  exit 1
fi


if [ ! -f "$versionFile" ]; then
  error_and_exit "missing version file: $versionFile"
fi

if [ -f "$versionFile" ]; then
  version=`cat $versionFile`
  baseName="${baseName}-${version}"
fi

if [ ! -f "$inputManifest" ]; then
  error_and_exit "missing input manifest: $inputManifest"
fi
if [ -z "$artifactId" ]; then
  error_and_exit "missing artifactId!"
fi
if [ -z "$packaging" ]; then
  error_and_exit "missing packaging!"
fi

inputWar=`find $inputDir -name '*.jar'`
outputWar="${outputDir}/${baseName}.jar"

echo "Renaming ${inputWar} to ${outputWar}"

cp ${inputWar} ${outputWar}

#AWS
# copy the manifest to the output directory and process it
echo "AWS Host: "$hostnameAWS
outputDirAWS=$outputDir/aws
mkdir $outputDir/aws
outputAWSManifest=$outputDirAWS/manifest.yml

cp ${outputWar} ${outputDirAWS}

cp $inputManifest $outputAWSManifest

# the path in the manifest is always relative to the manifest itself
sed -i -- "s|path: .*$|path: ${baseName}.jar|g" $outputAWSManifest


sed -i "s|host: .*$|host: $hostnameAWS|g" $outputAWSManifest

cat $outputAWSManifest

echo "Finished"

