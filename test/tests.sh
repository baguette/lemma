
for i in test/*.lua; do
	echo "$i..."
	lua $i
done

echo "Done."

