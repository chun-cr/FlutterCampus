"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExamCountdownController = void 0;
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
const create_exam_countdown_dto_1 = require("./dto/create-exam-countdown.dto");
const update_exam_countdown_dto_1 = require("./dto/update-exam-countdown.dto");
const exam_countdown_service_1 = require("./exam-countdown.service");
let ExamCountdownController = class ExamCountdownController {
    examCountdownService;
    constructor(examCountdownService) {
        this.examCountdownService = examCountdownService;
    }
    async list(request) {
        return this.examCountdownService.listByUser(request.user.userId);
    }
    async create(request, payload) {
        return this.examCountdownService.create(request.user.userId, payload);
    }
    async update(request, id, payload) {
        return this.examCountdownService.update(request.user.userId, id, payload);
    }
    async remove(request, id) {
        await this.examCountdownService.remove(request.user.userId, id);
        return { success: true };
    }
};
exports.ExamCountdownController = ExamCountdownController;
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], ExamCountdownController.prototype, "list", null);
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_exam_countdown_dto_1.CreateExamCountdownDto]),
    __metadata("design:returntype", Promise)
], ExamCountdownController.prototype, "create", null);
__decorate([
    (0, common_1.Put)(':id'),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, update_exam_countdown_dto_1.UpdateExamCountdownDto]),
    __metadata("design:returntype", Promise)
], ExamCountdownController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], ExamCountdownController.prototype, "remove", null);
exports.ExamCountdownController = ExamCountdownController = __decorate([
    (0, common_1.Controller)('exam-countdowns'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __metadata("design:paramtypes", [exam_countdown_service_1.ExamCountdownService])
], ExamCountdownController);
//# sourceMappingURL=exam-countdown.controller.js.map