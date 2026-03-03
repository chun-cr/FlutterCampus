import { Body, Controller, Delete, Get, Param, Post, Put, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { AuthUser } from '../auth/auth.types';
import { CreateGradeDto } from './dto/create-grade.dto';
import { UpdateGradeDto } from './dto/update-grade.dto';
import { GradesService } from './grades.service';

type AuthedRequest = Request & { user: AuthUser };

@Controller('grades')
@UseGuards(JwtAuthGuard)
export class GradesController {
  constructor(private readonly gradesService: GradesService) {}

  @Get()
  async list(@Req() request: AuthedRequest) {
    return this.gradesService.listByUser(request.user.userId);
  }

  @Post()
  async create(@Req() request: AuthedRequest, @Body() payload: CreateGradeDto) {
    return this.gradesService.create(request.user.userId, payload);
  }

  @Put(':id')
  async update(
    @Req() request: AuthedRequest,
    @Param('id') id: string,
    @Body() payload: UpdateGradeDto,
  ) {
    return this.gradesService.update(request.user.userId, id, payload);
  }

  @Delete(':id')
  async remove(@Req() request: AuthedRequest, @Param('id') id: string) {
    await this.gradesService.remove(request.user.userId, id);
    return { success: true };
  }
}
