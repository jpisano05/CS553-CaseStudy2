# Define constants
API_PORT="9005"
API_SERVER="paffenroth-23.dyn.wpi.edu"
HTTP_TIMEOUT_SECONDS="2"
HTTP_MAX_TIME_SECONDS="3"
# Check API
echo "Checking HTTP on http://${API_SERVER}:${API_PORT}/"
if curl -fv --connect-timeout "$HTTP_TIMEOUT_SECONDS" --max-time
"$HTTP_MAX_TIME_SECONDS" "http://${API_SERVER}:${API_PORT}/"; then
echo -e "\n\nHTTP is responding on port ${API_PORT}; no action taken."
exit 0
fi
echo "No HTTP response detected on port ${API_PORT}."