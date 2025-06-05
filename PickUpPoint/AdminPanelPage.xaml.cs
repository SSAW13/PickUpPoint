namespace PickUpPoint;
using System;
using System.Data;
using System.IO;
using System.Text;
using System.Threading.Tasks;
using System.Threading;
using Microsoft.Win32;
using Windows.Storage.Pickers;
using CommunityToolkit.Maui.Storage;
using CommunityToolkit.Maui.Alerts;
using CommunityToolkit.Maui.Core;

public partial class AdminPanelPage : ContentPage
{
    private DatabaseConnection _databaseConnection = new DatabaseConnection();
    public AdminPanelPage()
	{
		InitializeComponent();
	}

    private async void CreateNewUser(object sender, EventArgs e)
    {
        if (!string.IsNullOrWhiteSpace(LastnameEntry.Text) && !string.IsNullOrWhiteSpace(NameEntry.Text) && !string.IsNullOrWhiteSpace(LoginEntry.Text) && !string.IsNullOrWhiteSpace(PasswordEntry.Text))
        {
            string query = "select NewStaff(\'" + LastnameEntry.Text + "\', \'" + NameEntry.Text + "\', \'" + LoginEntry.Text + "\', \'" + PasswordEntry.Text + "\')";
            _databaseConnection.ExecuteNonQuery(query);
            await DisplayAlert("Уведомление", "Пользователь успешно создан!", "OK");
            LastnameEntry.Text = "";
            NameEntry.Text = "";
            LoginEntry.Text = "";
            PasswordEntry.Text = "";
        } else
        {
            await DisplayAlert("Ошибка","Заполните все поля","OK");
            LastnameEntry.Text = "";
            NameEntry.Text = "";
            LoginEntry.Text = "";
            PasswordEntry.Text = "";
        }
        
    }

    private async Task PickPlace(DataTable dataTable, string fileName)
    {
        try
        {
            string csvContent = ConvertDataTableToCsv(dataTable);

            using var stream = new MemoryStream();
            using (var writer = new StreamWriter(stream, Encoding.UTF8, leaveOpen: true))
            {
                await writer.WriteAsync(csvContent);
                await writer.FlushAsync();
            }
            stream.Position = 0;

            var fileSaverResult = await FileSaver.Default.SaveAsync(fileName, stream, CancellationToken.None);

            if (fileSaverResult.IsSuccessful)
            {
                await Shell.Current.DisplayAlert("Успех", $"Файл сохранён: {fileSaverResult.FilePath}", "OK");
            }
            else
            {
                await Shell.Current.DisplayAlert("Ошибка", "Не удалось сохранить файл", "OK");
            }
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", $"Ошибка при сохранении файла: {ex.Message}", "OK");
        }
    }

    private string ConvertDataTableToCsv(DataTable dataTable)
    {
        var sb = new StringBuilder();

        sb.AppendLine(string.Join(",",
            dataTable.Columns.Cast<DataColumn>()
                .Select(col => EscapeCsvValue(col.ColumnName))));

        foreach (DataRow row in dataTable.Rows)
        {
            var rowValues = row.ItemArray
                .Select(value => EscapeCsvValue(value?.ToString() ?? string.Empty));
            sb.AppendLine(string.Join(",", rowValues));
        }

        return sb.ToString();
    }

    private string EscapeCsvValue(string? value)
    {
        if (string.IsNullOrEmpty(value))
            return string.Empty;

        if (value.Contains(",") || value.Contains("\"") || value.Contains("\n"))
        {
            return $"\"{value.Replace("\"", "\"\"")}\"";
        }

        return value;
    }

    private async void ReportStaff(object sender, EventArgs e)
    {
        try
        {
            string query = "SELECT * FROM users";
            DataTable dataTable = _databaseConnection.ExecuteQuery(query);
            await PickPlace(dataTable, "ReportStaff.csv"); // Добавил расширение .csv
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", $"Ошибка при формировании отчёта: {ex.Message}", "OK");
        }
    }

    private async void ReportOrder(object sender, EventArgs e)
    {
        try
        {
            string query = "select * from orders where status_id = 1";
            DataTable dataTable = _databaseConnection.ExecuteQuery(query);
            await PickPlace(dataTable, "ReportOrder.csv");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", $"Ошибка при формировании отчёта: {ex.Message}", "OK");
        }
    }

    private async void ReportWriteOff(object sender, EventArgs e)
    {
        try
        {
            string query = "select * from orders where status_id = 3";
            DataTable dataTable = _databaseConnection.ExecuteQuery(query);
            await PickPlace(dataTable, "ReportWriteOff.csv");
        }
        catch (Exception ex)
        {
            await Shell.Current.DisplayAlert("Ошибка", $"Ошибка при формировании отчёта: {ex.Message}", "OK");
        }
    }
}