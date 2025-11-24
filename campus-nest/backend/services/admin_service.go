package services

import (
	"context"
	"encoding/csv"
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"golang.org/x/crypto/bcrypt"
)

type AdminService interface {
	AddStudent(studentData map[string]interface{}) error
	AddStudentsBatch(csvURL string) error
	SendAnnouncement(subject, message string, targets []string) error
	GetPlacementStats() (map[string]interface{}, error)
	GetCompanyAnalytics() (map[string]interface{}, error)
	CreateJobDrive(jobData map[string]interface{}) error
}

type AdminServiceImpl struct {
	userCollection *mongo.Collection
}


func (as *AdminServiceImpl) UserCollection() *mongo.Collection {
	return as.userCollection
}

func NewAdminService(db *mongo.Database) AdminService {
	return &AdminServiceImpl{
		userCollection: db.Collection("users"),
	}
}






func normalizeStudent(raw map[string]interface{}, defaultPwdHash string) map[string]interface{} {

	lower := make(map[string]interface{})
	for k, v := range raw {
		lower[strings.ToLower(k)] = v
	}

	out := make(map[string]interface{})


	setString := func(key string, aliases ...string) {

		var val interface{}
		if v, ok := lower[strings.ToLower(key)]; ok {
			val = v
		} else {
			for _, a := range aliases {
				if v, ok := lower[strings.ToLower(a)]; ok {
					val = v
					break
				}
			}
		}
		if val != nil {
			switch t := val.(type) {
			case string:
				out[key] = strings.TrimSpace(t)
			default:
				out[key] = fmt.Sprintf("%v", t)
			}
		}
	}

	setString("firstName")
	setString("lastName")
	setString("email")
	setString("rollNumber", "rollnumber")
	setString("department")
	setString("gender")
	setString("placedStatus", "placedstatus")


	if v, ok := lower["cgpa"]; ok {
		switch t := v.(type) {
		case float64:
			out["cgpa"] = t
		case float32:
			out["cgpa"] = float64(t)
		case int:
			out["cgpa"] = float64(t)
		case int64:
			out["cgpa"] = float64(t)
		case string:
			s := strings.TrimSpace(t)
			if s != "" {
				if f, err := strconv.ParseFloat(strings.ReplaceAll(s, ",", "."), 64); err == nil {
					out["cgpa"] = f
				} else {

					out["cgpa"] = s
				}
			}
		default:
			out["cgpa"] = t
		}
	}


	if v, ok := lower["skills"]; ok {
		switch t := v.(type) {
		case string:
			s := strings.TrimSpace(t)
			if s == "" {
				out["skills"] = []string{}
			} else {

				var parts []string
				if strings.Contains(s, ";") {
					parts = strings.Split(s, ";")
				} else if strings.Contains(s, ",") {
					parts = strings.Split(s, ",")
				} else {
					parts = strings.Fields(s)
				}
				var skills []string
				for _, p := range parts {
					if p = strings.TrimSpace(p); p != "" {
						skills = append(skills, p)
					}
				}
				out["skills"] = skills
			}
		case []string:
			out["skills"] = t
		case []interface{}:
			var skills []string
			for _, e := range t {
				skills = append(skills, fmt.Sprintf("%v", e))
			}
			out["skills"] = skills
		default:
			out["skills"] = []string{}
		}
	}


	out["role"] = "student"
	if _, ok := lower["passwordhash"]; ok {

		if v := lower["passwordhash"]; v != nil {
			out["passwordHash"] = fmt.Sprintf("%v", v)
		}
	} else {
		out["passwordHash"] = defaultPwdHash
	}

	return out
}

func (as *AdminServiceImpl) AddStudent(studentData map[string]interface{}) error {

	defaultPwd := "password123"
	pwdHash, _ := bcrypt.GenerateFromPassword([]byte(defaultPwd), bcrypt.DefaultCost)

	normalized := normalizeStudent(studentData, string(pwdHash))
	ctx := context.TODO()
	_, err := as.userCollection.InsertOne(ctx, normalized)
	return err
}

func (as *AdminServiceImpl) AddStudentsBatch(csvURL string) error {

	resp, err := http.Get(csvURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	reader := csv.NewReader(resp.Body)
	records, err := reader.ReadAll()
	if err != nil {
		return err
	}
	if len(records) < 2 {
		return fmt.Errorf("CSV must have header and at least one row")
	}
	header := records[0]
	var docs []interface{}

	defaultPwd := "password123"
	pwdHash, _ := bcrypt.GenerateFromPassword([]byte(defaultPwd), bcrypt.DefaultCost)

	for _, row := range records[1:] {

		if len(row) == 0 {
			continue
		}
		raw := make(map[string]interface{})
		for i, field := range header {
			if i >= len(row) {
				continue
			}
			raw[field] = strings.TrimSpace(row[i])
		}
		normalized := normalizeStudent(raw, string(pwdHash))
		docs = append(docs, normalized)
	}
	if len(docs) == 0 {
		return fmt.Errorf("No students to insert")
	}

	ctx := context.TODO()
	opts := options.InsertMany().SetOrdered(false)
	_, err = as.userCollection.InsertMany(ctx, docs, opts)
	return err
}

func (as *AdminServiceImpl) SendAnnouncement(subject, message string, targets []string) error {

	filter := map[string]interface{}{"role": map[string]interface{}{"$in": []string{"student", "tpo"}}}
	ctx := context.TODO()
	cursor, err := as.userCollection.Find(ctx, filter)
	if err != nil {
		return err
	}
	defer cursor.Close(ctx)
	var updates []mongo.WriteModel
	for cursor.Next(ctx) {
		var user map[string]interface{}
		if err := cursor.Decode(&user); err != nil {
			continue
		}
		notif := map[string]interface{}{
			"_id":       primitive.NewObjectID(),
			"subject":   subject,
			"message":   message,
			"isRead":    false,
			"createdAt": time.Now(),
		}
		update := mongo.NewUpdateOneModel()
		update.SetFilter(map[string]interface{}{"_id": user["_id"]})
		update.SetUpdate(map[string]interface{}{"$push": map[string]interface{}{"notifications": notif}})
		updates = append(updates, update)
	}
	if len(updates) == 0 {
		return fmt.Errorf("No users found to send announcement")
	}
	_, err = as.userCollection.BulkWrite(ctx, updates)
	return err
}

func (as *AdminServiceImpl) GetPlacementStats() (map[string]interface{}, error) {

	return as.GetPlacementStatsWithFilters(map[string]string{})
}

func (as *AdminServiceImpl) GetCompanyAnalytics() (map[string]interface{}, error) {

	return as.GetCompanyAnalyticsWithFilters(map[string]string{})
}


func (as *AdminServiceImpl) GetPlacementStatsWithFilters(filters map[string]string) (map[string]interface{}, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()


	var fromTime, toTime *time.Time
	if f, ok := filters["from"]; ok && f != "" {
		if t, err := time.Parse("2006-01-02", f); err == nil {
			fromTime = &t
		}
	}
	if tstr, ok := filters["to"]; ok && tstr != "" {
		if t, err := time.Parse("2006-01-02", tstr); err == nil {
			t = t.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
			toTime = &t
		}
	}

	match := bson.M{"role": "student"}
	if dept, ok := filters["department"]; ok && dept != "" {
		match["department"] = dept
	}
	if fromTime != nil || toTime != nil {
		dt := bson.M{}
		if fromTime != nil {
			dt["$gte"] = *fromTime
		}
		if toTime != nil {
			dt["$lte"] = *toTime
		}
		match["createdAt"] = dt
	}


	pipelineOverview := mongo.Pipeline{{{Key: "$match", Value: match}}, {{Key: "$group", Value: bson.M{"_id": "$placedStatus", "count": bson.M{"$sum": 1}}}}}
	curO, err := as.userCollection.Aggregate(ctx, pipelineOverview)
	if err != nil {
		return nil, err
	}
	defer curO.Close(ctx)
	overview := map[string]int64{}
	totalStudents := int64(0)
	for curO.Next(ctx) {
		var r struct {
			ID    interface{} `bson:"_id"`
			Count int64       `bson:"count"`
		}
		if err := curO.Decode(&r); err == nil {
			key := "Unknown"
			if r.ID != nil {
				key = fmt.Sprintf("%v", r.ID)
			}
			overview[key] = r.Count
			totalStudents += r.Count
		}
	}


	interval := "month"
	if iv, ok := filters["interval"]; ok && iv != "" {
		interval = iv
	}
	dateFormat := "%Y-%m"
	if interval == "week" {
		dateFormat = "%Y-%U"
	} else if interval == "day" {
		dateFormat = "%Y-%m-%d"
	}
	trendFrom := time.Now().AddDate(0, -11, 0)
	if fromTime != nil {
		trendFrom = *fromTime
	}
	matchTrend := bson.M{"role": "student", "createdAt": bson.M{"$gte": trendFrom}}
	if dept, ok := filters["department"]; ok && dept != "" {
		matchTrend["department"] = dept
	}
	pipelineTrend := mongo.Pipeline{
		{{Key: "$match", Value: matchTrend}},
		{{Key: "$project", Value: bson.M{"period": bson.M{"$dateToString": bson.M{"format": dateFormat, "date": "$createdAt"}}, "placedStatus": 1}}},
		{{Key: "$group", Value: bson.M{"_id": "$period", "total": bson.M{"$sum": 1}, "placed": bson.M{"$sum": bson.M{"$cond": bson.A{bson.M{"$eq": bson.A{"$placedStatus", "Placed"}}, 1, 0}}}}}},
		{{Key: "$sort", Value: bson.M{"_id": 1}}},
	}
	curT, _ := as.userCollection.Aggregate(ctx, pipelineTrend)
	var trendData []map[string]interface{}
	if curT != nil {
		defer curT.Close(ctx)
		for curT.Next(ctx) {
			var r bson.M
			if err := curT.Decode(&r); err == nil {
				period := fmt.Sprintf("%v", r["_id"])
				var total, placed int64
				if v, ok := r["total"].(int32); ok {
					total = int64(v)
				}
				if v, ok := r["total"].(int64); ok {
					total = v
				}
				if v, ok := r["placed"].(int32); ok {
					placed = int64(v)
				}
				if v, ok := r["placed"].(int64); ok {
					placed = v
				}
				rate := 0.0
				if total > 0 {
					rate = float64(placed) / float64(total) * 100
				}
				trendData = append(trendData, map[string]interface{}{"period": period, "total": total, "placed": placed, "placementRate": rate})
			}
		}
	}


	limit := int64(10)
	if lstr, ok := filters["limit"]; ok && lstr != "" {
		if v, err := strconv.ParseInt(lstr, 10, 64); err == nil {
			limit = v
		}
	}
	pipelineDept := mongo.Pipeline{
		{{Key: "$match", Value: bson.M{"role": "student"}}},
		{{Key: "$group", Value: bson.M{"_id": "$department", "total": bson.M{"$sum": 1}, "placed": bson.M{"$sum": bson.M{"$cond": bson.A{bson.M{"$eq": bson.A{"$placedStatus", "Placed"}}, 1, 0}}}}}},
		{{Key: "$sort", Value: bson.M{"total": -1}}},
		{{Key: "$limit", Value: limit}},
	}
	curD, _ := as.userCollection.Aggregate(ctx, pipelineDept)
	var deptData []map[string]interface{}
	if curD != nil {
		defer curD.Close(ctx)
		for curD.Next(ctx) {
			var r struct {
				ID     *string `bson:"_id"`
				Total  int64   `bson:"total"`
				Placed int64   `bson:"placed"`
			}
			if err := curD.Decode(&r); err == nil {
				name := "Unknown"
				if r.ID != nil {
					name = *r.ID
				}
				rate := 0.0
				if r.Total > 0 {
					rate = float64(r.Placed) / float64(r.Total) * 100
				}
				deptData = append(deptData, map[string]interface{}{"department": name, "totalStudents": r.Total, "placed": r.Placed, "placementRate": rate})
			}
		}
	}


	drivesN := int64(6)
	if dstr, ok := filters["drives"]; ok && dstr != "" {
		if v, err := strconv.ParseInt(dstr, 10, 64); err == nil {
			drivesN = v
		}
	}
	jobsCol := as.userCollection.Database().Collection("jobs")
	jobOpts := options.Find().SetSort(bson.M{"createdAt": -1}).SetLimit(drivesN)
	jobCur, _ := jobsCol.Find(ctx, bson.M{}, jobOpts)
	var recentDrives []map[string]interface{}
	if jobCur != nil {
		defer jobCur.Close(ctx)
		for jobCur.Next(ctx) {
			var job bson.M
			if err := jobCur.Decode(&job); err != nil {
				continue
			}
			jid, _ := job["_id"].(primitive.ObjectID)
			title := fmt.Sprintf("%v", job["position"])
			postedAt := job["createdAt"]
			appCol := as.userCollection.Database().Collection("applications")
			pipelineApps := mongo.Pipeline{{{Key: "$match", Value: bson.M{"jobId": jid}}}, {{Key: "$group", Value: bson.M{"_id": "$status", "count": bson.M{"$sum": 1}}}}}
			appCur, _ := appCol.Aggregate(ctx, pipelineApps)
			counts := map[string]int64{}
			if appCur != nil {
				for appCur.Next(ctx) {
					var r struct {
						ID    string `bson:"_id"`
						Count int64  `bson:"count"`
					}
					if err := appCur.Decode(&r); err == nil {
						counts[r.ID] = r.Count
					}
				}
				appCur.Close(ctx)
			}
			recentDrives = append(recentDrives, map[string]interface{}{"jobId": jid, "title": title, "postedAt": postedAt, "applicants": counts["applied"] + counts[""], "shortlisted": counts["shortlisted"], "interviewed": counts["interviewed"], "offers": counts["selected"] + counts["offered"]})
		}
	}

	resp := map[string]interface{}{
		"overview":     map[string]interface{}{"totalStudents": totalStudents, "byStatus": overview},
		"trend":        map[string]interface{}{"interval": interval, "data": trendData},
		"departments":  deptData,
		"recentDrives": recentDrives,
	}
	return resp, nil
}


func (as *AdminServiceImpl) GetCompanyAnalyticsWithFilters(filters map[string]string) (map[string]interface{}, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 25*time.Second)
	defer cancel()
	limit := int64(10)
	if lstr, ok := filters["limit"]; ok && lstr != "" {
		if v, err := strconv.ParseInt(lstr, 10, 64); err == nil {
			limit = v
		}
	}
	appCol := as.userCollection.Database().Collection("applications")
	jobsCol := as.userCollection.Database().Collection("jobs")
	companiesCol := as.userCollection.Database().Collection("companies")


	pipelineHires := mongo.Pipeline{
		{{Key: "$match", Value: bson.M{"status": "selected"}}},
		{{Key: "$lookup", Value: bson.M{
			"from":         "jobs",
			"localField":   "job_id",
			"foreignField": "_id",
			"as":           "job",
		}}},
		{{Key: "$unwind", Value: bson.M{"path": "$job", "preserveNullAndEmptyArrays": true}}},
		{{Key: "$group", Value: bson.M{
			"_id":   "$job.company_name.companyId",
			"hires": bson.M{"$sum": 1},
		}}},
		{{Key: "$sort", Value: bson.M{"hires": -1}}},
		{{Key: "$limit", Value: limit}},
	}
	curH, _ := appCol.Aggregate(ctx, pipelineHires)
	var topByHires []map[string]interface{}
	if curH != nil {
		defer curH.Close(ctx)
		for curH.Next(ctx) {
			var r struct {
				ID    *primitive.ObjectID `bson:"_id"`
				Hires int64               `bson:"hires"`
			}
			if err := curH.Decode(&r); err == nil {
				compName := "Unknown"
				var compID interface{} = nil
				if r.ID != nil {
					compID = r.ID
					var comp bson.M
					if err := companiesCol.FindOne(ctx, bson.M{"_id": *r.ID}).Decode(&comp); err == nil {
						compName = fmt.Sprintf("%v", comp["name"])
					}
				}
				topByHires = append(topByHires, map[string]interface{}{
					"companyId":   compID,
					"companyName": compName,
					"hires":       r.Hires,
				})
			}
		}
	}


	pipelineDrives := mongo.Pipeline{
		{{Key: "$group", Value: bson.M{
			"_id":           "$company_name.companyId",
			"jobDriveCount": bson.M{"$sum": 1},
		}}},
		{{Key: "$sort", Value: bson.M{"jobDriveCount": -1}}},
		{{Key: "$limit", Value: limit}},
	}
	curD, _ := jobsCol.Aggregate(ctx, pipelineDrives)
	var topByDrives []map[string]interface{}
	if curD != nil {
		defer curD.Close(ctx)
		for curD.Next(ctx) {
			var r struct {
				ID    *primitive.ObjectID `bson:"_id"`
				Count int64               `bson:"jobDriveCount"`
			}
			if err := curD.Decode(&r); err == nil {
				compName := "Unknown"
				var compID interface{} = nil
				if r.ID != nil {
					compID = r.ID
					var comp bson.M
					if err := companiesCol.FindOne(ctx, bson.M{"_id": *r.ID}).Decode(&comp); err == nil {
						compName = fmt.Sprintf("%v", comp["name"])
					}
				}
				topByDrives = append(topByDrives, map[string]interface{}{
					"companyId":     compID,
					"companyName":   compName,
					"jobDriveCount": r.Count,
				})
			}
		}
	}

	companyCount, _ := companiesCol.CountDocuments(ctx, bson.M{})
	activeDrives, _ := jobsCol.CountDocuments(ctx, bson.M{})
	resp := map[string]interface{}{
		"topByHires":  topByHires,
		"topByDrives": topByDrives,
		"summary": map[string]interface{}{
			"totalCompanies": companyCount,
			"activeDrives":   activeDrives,
		},
	}
	return resp, nil
}

func (as *AdminServiceImpl) CreateJobDrive(jobData map[string]interface{}) error {

	jobData["createdAt"] = nil
	ctx := context.TODO()
	_, err := as.userCollection.Database().Collection("jobs").InsertOne(ctx, jobData)
	return err
}
