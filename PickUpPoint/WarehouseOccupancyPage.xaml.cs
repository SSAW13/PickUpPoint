namespace PickUpPoint;

using Microsoft.Maui.Controls;

public partial class WarehouseOccupancyPage : ContentPage
{
    public WarehouseOccupancyPage()
    {
        InitializeComponent();
        CreateOrderGrid();
    }

    private void CreateOrderGrid()
    {
        const int squareSize = 50;
        const int columns = 10;
        const int rows = 5;

        for (int i = 0; i < columns; i++)
            SquaresGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = squareSize });

        for (int i = 0; i < rows; i++)
            SquaresGrid.RowDefinitions.Add(new RowDefinition { Height = squareSize });

        for (int row = 0; row < rows; row++)
        {
            for (int col = 0; col < columns; col++)
            {
                var square = new Frame
                {
                    WidthRequest = squareSize,
                    HeightRequest = squareSize,
                    CornerRadius = 8,
                    BackgroundColor = Colors.LightGreen,
                    Padding = 0
                };

                Grid.SetRow(square, row);
                Grid.SetColumn(square, col);
                SquaresGrid.Children.Add(square);
            }
        }
    }
}