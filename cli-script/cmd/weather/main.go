package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"text/template"

	"github.com/bitfield/script"
)

const (
	WeatherURL = `https://api.open-meteo.com/v1/forecast?latitude=45.5088&longitude=-73.5878&daily=weathercode,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,sunrise,sunset,uv_index_max,precipitation_sum,rain_sum,showers_sum,snowfall_sum,precipitation_hours,precipitation_probability_max,windspeed_10m_max,windgusts_10m_max,winddirection_10m_dominant&current_weather=true&timezone=America%2FNew_York&forecast_days=3`
)

type WeatherResponse struct {
	CurrentWeather struct {
		IsDay         uint    `json:"is_day"`
		Temperature   float64 `json:"temperature"`
		Time          string  `json:"time"`
		Weathercode   int64   `json:"weathercode"`
		Winddirection int64   `json:"winddirection"`
		Windspeed     float64 `json:"windspeed"`
	} `json:"current_weather"`
	Daily struct {
		ApparentTemperatureMax      []float64 `json:"apparent_temperature_max"`
		ApparentTemperatureMin      []float64 `json:"apparent_temperature_min"`
		PrecipitationHours          []float64 `json:"precipitation_hours"`
		PrecipitationProbabilityMax []int64   `json:"precipitation_probability_max"`
		PrecipitationSum            []float64 `json:"precipitation_sum"`
		RainSum                     []float64 `json:"rain_sum"`
		ShowersSum                  []float64 `json:"showers_sum"`
		SnowfallSum                 []float64 `json:"snowfall_sum"`
		Sunrise                     []string  `json:"sunrise"`
		Sunset                      []string  `json:"sunset"`
		Temperature2mMax            []float64 `json:"temperature_2m_max"`
		Temperature2mMin            []float64 `json:"temperature_2m_min"`
		Time                        []string  `json:"time"`
		UVIndexMax                  []float64 `json:"uv_index_max"`
		Weathercode                 []int64   `json:"weathercode"`
		Winddirection10mDominant    []int64   `json:"winddirection_10m_dominant"`
		Windgusts10mMax             []float64 `json:"windgusts_10m_max"`
		Windspeed10mMax             []float64 `json:"windspeed_10m_max"`
	} `json:"daily"`
	DailyUnits struct {
		ApparentTemperatureMax      string `json:"apparent_temperature_max"`
		ApparentTemperatureMin      string `json:"apparent_temperature_min"`
		PrecipitationHours          string `json:"precipitation_hours"`
		PrecipitationProbabilityMax string `json:"precipitation_probability_max"`
		PrecipitationSum            string `json:"precipitation_sum"`
		RainSum                     string `json:"rain_sum"`
		ShowersSum                  string `json:"showers_sum"`
		SnowfallSum                 string `json:"snowfall_sum"`
		Sunrise                     string `json:"sunrise"`
		Sunset                      string `json:"sunset"`
		Temperature2mMax            string `json:"temperature_2m_max"`
		Temperature2mMin            string `json:"temperature_2m_min"`
		Time                        string `json:"time"`
		UVIndexMax                  string `json:"uv_index_max"`
		Weathercode                 string `json:"weathercode"`
		Winddirection10mDominant    string `json:"winddirection_10m_dominant"`
		Windgusts10mMax             string `json:"windgusts_10m_max"`
		Windspeed10mMax             string `json:"windspeed_10m_max"`
	} `json:"daily_units"`
	Elevation            float64 `json:"elevation"`
	GenerationtimeMS     float64 `json:"generationtime_ms"`
	Latitude             float64 `json:"latitude"`
	Longitude            float64 `json:"longitude"`
	Timezone             string  `json:"timezone"`
	TimezoneAbbreviation string  `json:"timezone_abbreviation"`
	UTCOffsetSeconds     int64   `json:"utc_offset_seconds"`
}

const weatherReportTemplate = `{{ .CurrentWeather.Temperature }} ℃ | {{ if .CurrentWeather.IsDay }}🌞{{ else }}🌚{{end}}
`

func mainWithErrorNumber() int {
	if _, err := script.Get(WeatherURL).Filter(func(r io.Reader, w io.Writer) error {
		bs, err := io.ReadAll(r)
		if err != nil {
			return err
		}

		var resp WeatherResponse
		if err := json.Unmarshal(bs, &resp); err != nil {
			return fmt.Errorf("error unmarshaling JSON: %w", err)
		}

		tmpl, err := template.New("weather").Parse(weatherReportTemplate)
		if err != nil {
			return fmt.Errorf("error parsing template: %w", err)
		}

		if err := tmpl.Execute(w, &resp); err != nil {
			return fmt.Errorf("error executing template: %w", err)
		}

		return nil
	}).Stdout(); err != nil {
		log.Fatal(err)
	}

	return 0
}

func main() {
	os.Exit(mainWithErrorNumber())
}
