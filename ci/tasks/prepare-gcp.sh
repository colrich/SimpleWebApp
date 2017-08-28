#!/bin/bash

baseName="pcf-demo"

inputDir=     # required
outputDir=    # required
versionFile=  # optional
inputManifest=  # optional
artifactId=  # optional
packaging= # optional

#
hostnameGCP=$CF_MANIFEST_HOST_GCP # default to env variable from pipeline


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

inputWar=`find $inputDir -name '*.war'`
outputWar="${outputDir}/${baseName}.war"

echo "Renaming ${inputWar} to ${outputWar}"

cp ${inputWar} ${outputWar}

#AWS
# copy the manifest to the output directory and process it
echo "GCP Host: "$hostnameGCP
outputDirGCP=$outputDir/gcp
mkdir $outputDir/gcp
outputGCPManifest=$outputDirGCP/manifest.yml

cp ${outputWar} ${outputDirGCP}

cp $inputManifest $outputGCPManifest

# the path in the manifest is always relative to the manifest itself
sed -i -- "s|path: .*$|path: ${baseName}.war|g" $outputGCPManifest


sed -i "s|host: .*$|host: $hostnameGCP|g" $outputGCPManifest

cat $outputGCPManifest

echo "Finished"

