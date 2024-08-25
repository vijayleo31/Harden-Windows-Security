using System;
using System.Linq;
using System.Management;
using System.Dynamic;
using System.Globalization;
using System.Collections.Generic;
using System.Collections;

#nullable enable

namespace HardenWindowsSecurity
{
    public static class MpComputerStatusHelper
    {
        // Get the MpComputerStatus from the MSFT_MpComputerStatus WMI class and returns it as a dynamic object
        public static dynamic GetMpComputerStatus()
        {
            try
            {
                // Define the WMI query to retrieve the MpComputerStatus
                string namespaceName = "ROOT\\Microsoft\\Windows\\Defender";
                string className = "MSFT_MpComputerStatus";
                string queryString = $"SELECT * FROM {className}";

                // Execute the query
                ManagementObjectSearcher searcher = new ManagementObjectSearcher(namespaceName, queryString);
                ManagementObjectCollection results = searcher.Get();

                // Make sure the results isn't empty
                if (results.Count > 0)
                {
                    var result = results.Cast<ManagementBaseObject>().FirstOrDefault();

                    if (result != null)
                    {

                        return ConvertToDynamic(result);
                    }
                    else
                    {
                        throw new Exception("Failed to get MpComputerStatus!");
                    }
                }
                else
                {
                    throw new HardenWindowsSecurity.PowerShellExecutionException("WMI query for 'MSFT_MpComputerStatus' failed");
                }
            }
            catch (ManagementException ex)
            {
                string errorMessage = $"WMI query for 'MSFT_MpComputerStatus' failed: {ex.Message}";
                throw new HardenWindowsSecurity.PowerShellExecutionException(errorMessage, ex);
            }
        }

        // Convert the ManagementBaseObject to a dynamic object
        private static dynamic ConvertToDynamic(ManagementBaseObject managementObject)
        {
            // Creating a dynamic object to store the properties of the ManagementBaseObject
            dynamic expandoObject = new ExpandoObject();
            var dictionary = (IDictionary<string, object>)expandoObject;

            foreach (var property in managementObject.Properties)
            {
                if (property.Type == CimType.DateTime && property.Value is string dmtfTime)
                {
                    dictionary[property.Name] = ConvertDmtfToDateTime(dmtfTime);
                }
                else
                {
                    dictionary[property.Name] = property.Value;
                }
            }

            return expandoObject;
        }

        // Convert DMTF datetime format to DateTime
        private static DateTime ConvertDmtfToDateTime(string dmtfTime)
        {
            // DMTF datetime format: yyyymmddHHMMSS.mmmmmmsUUU
            if (ManagementDateTimeConverter.ToDateTime(dmtfTime) is DateTime dateTime)
            {
                return dateTime;
            }

            throw new FormatException($"Invalid DMTF datetime format: {dmtfTime}");
        }


        /// <summary>
        /// The Set-MpPreference command but implemented from scratch for the Harden Windows Security application
        /// </summary>
        /// <typeparam name="T">The type of the value to set the Microsoft Defender feature to</typeparam>
        /// <param name="preferenceName">The name of the Microsoft Defender feature to configure</param>
        /// <param name="preferenceValue">The value to set the Microsoft Defender feature to</param>
        public static void SetMpComputerStatus<T>(string preferenceName, T preferenceValue)
        {
            try
            {
                // Connect to the WMI namespace
                var scope = new ManagementScope(@"\\.\ROOT\Microsoft\Windows\Defender");
                scope.Connect();

                // Create an instance of the MSFT_MpPreference class
                var mpPreferenceClass = new ManagementClass(scope, new ManagementPath("MSFT_MpPreference"), null);

                // Get the available methods for the class
                var methodParams = mpPreferenceClass.GetMethodParameters("Set");

                if (preferenceValue == null)
                {
                    throw new ArgumentNullException(nameof(preferenceValue));
                }

                // Set the preference based on the type T
                if (typeof(T) == typeof(string))
                {
                    methodParams[preferenceName] = (string)(object)preferenceValue;
                }
                else if (typeof(T) == typeof(bool))
                {
                    methodParams[preferenceName] = (bool)(object)preferenceValue;
                }
                else if (typeof(T) == typeof(int))
                {
                    methodParams[preferenceName] = (int)(object)preferenceValue;
                }
                else if (typeof(T) == typeof(double))
                {
                    methodParams[preferenceName] = (double)(object)preferenceValue;
                }
                else if (typeof(T) == typeof(float))
                {
                    methodParams[preferenceName] = (float)(object)preferenceValue;
                }
                else if (typeof(T) == typeof(string[]))
                {
                    methodParams[preferenceName] = (string[])(object)preferenceValue;
                }
                else if (typeof(T) == typeof(byte))
                {
                    methodParams[preferenceName] = (byte)(object)preferenceValue;
                }
                else if (typeof(ushort) == typeof(ushort))
                {
                    methodParams[preferenceName] = (ushort)(object)preferenceValue;
                }
                else
                {
                    throw new ArgumentException($"Unsupported type {typeof(T)} for preference value");
                }

                // Invoke the method to apply the settings
                mpPreferenceClass.InvokeMethod("Set", methodParams, null);

                HardenWindowsSecurity.Logger.LogMessage($"{preferenceName} set to {preferenceValue} (Type: {typeof(T).Name}) successfully.");
            }
            catch (Exception ex)
            {
                HardenWindowsSecurity.Logger.LogMessage($"Error setting {preferenceName}: {ex.Message}- You might need you Update your OS first.");
            }
        }
    }
}