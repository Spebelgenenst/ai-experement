clear
sleep 1
echo "--- BUILD STARTED ---"
sleep 1
swift build
echo "--- BUILD COMPLETED ---"
echo "You can find the Build in a subfolder of the Build Directory: (./build), for example: ./build/arm64-apple-macosx/debug/ai-experiment"
